import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/ticket.dart';
import '../../data/models/activity.dart';
import '../../data/services/ticket_service.dart';

class AddTicketScreenV2 extends StatefulWidget {
  final String tripId;
  final List<Activity>? activities;
  final Ticket? ticketToEdit;

  const AddTicketScreenV2({
    super.key,
    required this.tripId,
    this.activities,
    this.ticketToEdit,
  });

  @override
  State<AddTicketScreenV2> createState() => _AddTicketScreenV2State();
}

class _AddTicketScreenV2State extends State<AddTicketScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _notesController = TextEditingController();
  final _ticketService = TicketService();
  final _imagePicker = ImagePicker();

  TicketType _selectedType = TicketType.bus;
  DateTime _selectedDatetime = DateTime.now();
  TicketStatus _selectedStatus = TicketStatus.notBooked;
  File? _selectedImage;
  String? _existingImagePath;
  String? _selectedActivityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticketToEdit != null) {
      _loadTicketData();
    }
  }

  void _loadTicketData() {
    final ticket = widget.ticketToEdit!;
    _nameController.text = ticket.name;
    _codeController.text = ticket.code;
    _fromController.text = ticket.from ?? '';
    _toController.text = ticket.to ?? '';
    _notesController.text = ticket.notes ?? '';
    _selectedType = ticket.type;
    _selectedDatetime = ticket.datetime;
    _selectedStatus = ticket.status;
    _existingImagePath = ticket.imagePath;
    _selectedActivityId = ticket.linkedActivityId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _existingImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _existingImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_selectedImage != null || _existingImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _existingImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDatetime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDatetime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDatetime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDatetime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  IconData _getTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return Icons.directions_bus;
      case TicketType.train:
        return Icons.train;
      case TicketType.flight:
        return Icons.flight;
      case TicketType.hotel:
        return Icons.hotel;
    }
  }

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ticketId = widget.ticketToEdit?.id ?? const Uuid().v4();
      String? imagePath = _existingImagePath;

      if (_selectedImage != null) {
        if (_existingImagePath != null) {
          await _ticketService.deleteTicketImage(_existingImagePath!);
        }
        imagePath = await _ticketService.saveTicketImage(_selectedImage!, ticketId);
      }

      final ticket = Ticket(
        id: ticketId,
        type: _selectedType,
        name: _nameController.text.trim(),
        datetime: _selectedDatetime,
        code: _codeController.text.trim(),
        from: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
        to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
        imagePath: imagePath,
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        tripId: widget.tripId,
        linkedActivityId: _selectedActivityId,
      );

      if (widget.ticketToEdit != null) {
        await _ticketService.updateTicket(ticket);
      } else {
        await _ticketService.addTicket(ticket);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu vé: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticketToEdit != null ? 'Chỉnh sửa vé' : 'Thêm vé mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : _existingImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_existingImagePath!), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Thêm ảnh vé', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            // Ticket type
            const Text('Loại vé *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: TicketType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(type), size: 18),
                      const SizedBox(width: 8),
                      Text(Ticket(
                        id: '',
                        type: type,
                        name: '',
                        datetime: DateTime.now(),
                        code: '',
                        tripId: '',
                      ).typeDisplayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Ticket name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên vé *',
                hintText: 'VD: Vé xe Hà Nội - Đà Nẵng',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên vé';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // From - To
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fromController,
                    decoration: const InputDecoration(
                      labelText: 'Điểm đi',
                      hintText: 'Hà Nội',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      labelText: 'Điểm đến',
                      hintText: 'Đà Nẵng',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Datetime
            InkWell(
              onTap: _selectDatetime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày giờ *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_selectedDatetime),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Code
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Mã vé *',
                hintText: 'ABC123456',
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã vé';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<TicketStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: TicketStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(Ticket(
                    id: '',
                    type: TicketType.bus,
                    name: '',
                    datetime: DateTime.now(),
                    code: '',
                    tripId: '',
                    status: status,
                  ).statusDisplayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Link activity
            if (widget.activities != null && widget.activities!.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedActivityId,
                decoration: const InputDecoration(
                  labelText: 'Liên kết với hoạt động (tùy chọn)',
                  prefixIcon: Icon(Icons.link),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    child: Text('Không liên kết'),
                  ),
                  ...widget.activities!.map((activity) {
                    return DropdownMenuItem<String>(
                      value: activity.id,
                      child: Text(activity.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Thêm ghi chú về vé...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTicket,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(widget.ticketToEdit != null ? 'Cập nhật' : 'Lưu vé'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
