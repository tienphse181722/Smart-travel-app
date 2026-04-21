import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/ticket.dart';
import '../models/activity.dart';
import '../services/ticket_service.dart';

class AddTicketScreen extends StatefulWidget {
  final String tripId;
  final List<Activity>? activities;
  final Ticket? ticketToEdit;

  const AddTicketScreen({
    super.key,
    required this.tripId,
    this.activities,
    this.ticketToEdit,
  });

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ticketCodeController = TextEditingController();
  final _bookingUrlController = TextEditingController();
  final _notesController = TextEditingController();
  final _ticketService = TicketService();
  final _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
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
    _ticketCodeController.text = ticket.ticketCode;
    _bookingUrlController.text = ticket.bookingUrl ?? '';
    _notesController.text = ticket.notes ?? '';
    _selectedDate = ticket.date;
    _existingImagePath = ticket.imagePath;
    _selectedActivityId = ticket.activityId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketCodeController.dispose();
    _bookingUrlController.dispose();
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
          _existingImagePath = null; // Clear existing image if new one is selected
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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

      // Save new image if selected
      if (_selectedImage != null) {
        // Delete old image if editing
        if (_existingImagePath != null) {
          await _ticketService.deleteTicketImage(_existingImagePath!);
        }
        imagePath = await _ticketService.saveTicketImage(_selectedImage!, ticketId);
      }

      final ticket = Ticket(
        id: ticketId,
        name: _nameController.text.trim(),
        date: _selectedDate,
        ticketCode: _ticketCodeController.text.trim(),
        imagePath: imagePath,
        bookingUrl: _bookingUrlController.text.trim().isEmpty
            ? null
            : _bookingUrlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tripId: widget.tripId,
        activityId: _selectedActivityId,
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
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _existingImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_existingImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thêm ảnh vé',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            // Ticket name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên vé *',
                hintText: 'VD: Vé máy bay Hà Nội - Đà Nẵng',
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

            // Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày giờ *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ticket code
            TextFormField(
              controller: _ticketCodeController,
              decoration: const InputDecoration(
                labelText: 'Mã vé *',
                hintText: 'VD: ABC123456',
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

            // Link activity (optional)
            if (widget.activities != null && widget.activities!.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedActivityId,
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

            // Booking URL (optional)
            TextFormField(
              controller: _bookingUrlController,
              decoration: const InputDecoration(
                labelText: 'Link đặt vé/khách sạn (tùy chọn)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

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
