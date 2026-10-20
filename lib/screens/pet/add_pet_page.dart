import 'package:flutter/material.dart';
import '../../data/pet_repository.dart';
import '../../models/pet.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key, this.pet});

  final Pet? pet;

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bg = Color(0xFFF5F6F7);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _allergyCtrl;

  String _species = 'Chó';
  String _gender = 'Đực';
  bool _neutered = false;

  bool get _isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final Pet? p = widget.pet;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _breedCtrl = TextEditingController(text: p?.breed ?? '');
    _ageCtrl = TextEditingController(text: p != null ? '${p.ageYears}' : '');
    _weightCtrl = TextEditingController(text: p != null ? '${p.weightKg}' : '');
    _allergyCtrl = TextEditingController(
      text: p != null ? p.allergies.join(', ') : '',
    );
    _species = p?.species ?? 'Chó';
    _gender = p?.gender ?? 'Đực';
    _neutered = p?.neutered ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          _isEdit ? 'Chỉnh sửa hồ sơ' : 'Thêm thú cưng',
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _label('Tên thú cưng'),
              _field(_nameCtrl, 'Ví dụ: Miu', required: true),
              const SizedBox(height: 16),
              _label('Loài'),
              _chips(
                <String>['Chó', 'Mèo', 'Khác'],
                _species,
                (String v) => setState(() => _species = v),
              ),
              const SizedBox(height: 16),
              _label('Giống'),
              _field(_breedCtrl, 'Ví dụ: Mèo Anh lông ngắn'),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(child: _label('Tuổi (năm)')),
                  const SizedBox(width: 12),
                  Expanded(child: _label('Cân nặng (kg)')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(child: _numberField(_ageCtrl, '2')),
                  const SizedBox(width: 12),
                  Expanded(child: _numberField(_weightCtrl, '4.2')),
                ],
              ),
              const SizedBox(height: 16),
              _label('Giới tính'),
              _chips(
                <String>['Đực', 'Cái'],
                _gender,
                (String v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Đã triệt sản', style: TextStyle(fontSize: 14)),
                value: _neutered,
                activeColor: primary,
                onChanged: (bool v) => setState(() => _neutered = v),
              ),
              const SizedBox(height: 8),
              _label('Dị ứng (cách nhau bởi dấu phẩy)'),
              _field(_allergyCtrl, 'Ví dụ: Thịt gà, Sữa'),
              const SizedBox(height: 24),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    bool required = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Vui lòng nhập thông tin';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _chips(List<String> items, String selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      children: items.map((String item) {
        final bool active = item == selected;
        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: active ? primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? primary : const Color(0xFFE3E5EA)),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _save,
        child: Text(
          _isEdit ? 'Lưu thay đổi' : 'Thêm thú cưng',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final int age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final double weight = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    final List<String> allergies = _allergyCtrl.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    final Pet? existing = widget.pet;
    if (existing != null) {
      PetRepository.updatePet(
        existing.copyWith(
          name: _nameCtrl.text.trim(),
          species: _species,
          breed: _breedCtrl.text.trim(),
          ageYears: age,
          weightKg: weight,
          gender: _gender,
          neutered: _neutered,
          allergies: allergies,
        ),
      );
    } else {
      PetRepository.addPet(
        Pet(
          id: PetRepository.nextId(),
          name: _nameCtrl.text.trim(),
          species: _species,
          breed: _breedCtrl.text.trim(),
          ageYears: age,
          weightKg: weight,
          gender: _gender,
          neutered: _neutered,
          allergies: allergies,
          weights: <WeightRecord>[
            WeightRecord(date: DateTime.now(), kg: weight),
          ],
        ),
      );
    }
    Navigator.of(context).pop(true);
  }
}
