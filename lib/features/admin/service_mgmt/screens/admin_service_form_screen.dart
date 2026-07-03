import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../customer/service/models/service_model.dart';
import '../../../customer/service/providers/service_provider.dart';

/// Admin service form screen for adding or editing a service.
///
/// Fields: name, category, price, duration, description, active status.
class AdminServiceFormScreen extends ConsumerStatefulWidget {
  final String? serviceId;

  const AdminServiceFormScreen({super.key, this.serviceId});

  @override
  ConsumerState<AdminServiceFormScreen> createState() => _AdminServiceFormScreenState();
}

class _AdminServiceFormScreenState extends ConsumerState<AdminServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _aktif = true;
  bool _isSaving = false;
  bool _isLoading = false;

  bool get isEditing => widget.serviceId != null && widget.serviceId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    setState(() => _isLoading = true);
    final service = await ref.read(serviceByIdProvider(widget.serviceId!).future);
    if (service != null && mounted) {
      _nameController.text = service.nama;
      _categoryController.text = service.kategori;
      _priceController.text = service.harga.toString();
      _durationController.text = service.durasi.toString();
      _descriptionController.text = service.deskripsi;
      _aktif = service.aktif;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(serviceServiceProvider);
      final data = {
        'nama': _nameController.text.trim(),
        'kategori': _categoryController.text.trim(),
        'harga': int.parse(_priceController.text),
        'durasi': int.parse(_durationController.text),
        'deskripsi': _descriptionController.text.trim(),
        'aktif': _aktif,
      };

      if (isEditing) {
        await service.updateService(widget.serviceId!, data);
      } else {
        await service.createService(ServiceModel(
          id: '',
          nama: data['nama'] as String,
          harga: data['harga'] as int,
          durasi: data['durasi'] as int,
          deskripsi: data['deskripsi'] as String,
          aktif: data['aktif'] as bool,
          kategori: data['kategori'] as String,
          createdAt: DateTime.now(),
        ));
      }

      if (mounted) {
        SnackbarHelper.success(context, isEditing ? 'Service updated!' : 'Service created!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarHelper.error(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Service' : 'Add Service')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Service' : 'Add Service'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),

      body: SingleChildScrollView(

  padding: const EdgeInsets.all(
    AppDimensions.spacingXL,
  ),

  child: Form(

    key: _formKey,

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        //=========================
        // HEADER
        //=========================

        Center(

          child: Column(

            children: [

              CircleAvatar(

                radius:42,

                backgroundColor:
                    AppColors.gold,

                child: const Icon(
                  Icons.miscellaneous_services,
                  color: Colors.white,
                  size:38,
                ),

              ),

              const SizedBox(height:15),

              Text(

                isEditing
                ? "Edit Service"
                : "Tambah Service",

                style: const TextStyle(

                  fontSize:22,
                  fontWeight:
                      FontWeight.bold,

                ),

              ),

            ],

          ),

        ),

        const SizedBox(height:30),

        //=========================
        // SERVICE NAME
        //=========================

        CustomTextField(

          controller:_nameController,

          label:"Service Name",

          hintText:"Haircut Classic",

          prefixIcon:
              Icons.content_cut,

          validator:(v){

            if(v==null ||
               v.trim().isEmpty){

              return
              "Nama service wajib";

            }

            return null;

          },

        ),

        const SizedBox(
          height:
          AppDimensions.spacingLG,
        ),

        //=========================
        // CATEGORY
        //=========================

        DropdownButtonFormField<String> (

          initialValue:
          _categoryController.text.isEmpty
          ? null
          : _categoryController.text,

          decoration:InputDecoration(

            labelText:"Category",

            prefixIcon:
            const Icon(Icons.category),

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(
              AppDimensions.radiusMD),

            ),

          ),

          items: const [

            DropdownMenuItem(
              value:"Haircut",
              child:Text("Haircut"),
            ),

            DropdownMenuItem(
              value:"Shaving",
              child:Text("Shaving"),
            ),

            DropdownMenuItem(
              value:"Hair Coloring",
              child:Text("Hair Coloring"),
            ),

            DropdownMenuItem(
              value:"Treatment",
              child:Text("Treatment"),
            ),

            DropdownMenuItem(
              value:"Kids",
              child:Text("Kids"),
            ),

          ],

          onChanged:(value){

            _categoryController.text =
            value!;

          },

          validator:(value){

            if(value==null){

              return
              "Category wajib dipilih";

            }

            return null;

          },

        ),

        const SizedBox(
          height:
          AppDimensions.spacingLG,
        ),

        //=========================
        // PRICE + DURATION
        //=========================

        Row(

          children:[

            Expanded(

              child: CustomTextField(

                controller:
                _priceController,

                label:"Price",

                hintText:"50000",

                keyboardType:
                TextInputType.number,

                prefixIcon:
                Icons.attach_money,

              ),

            ),

            const SizedBox(width:15),

            Expanded(

              child: CustomTextField(

                controller:
                _durationController,

                label:"Duration",

                hintText:"30",

                keyboardType:
                TextInputType.number,

                prefixIcon:
                Icons.timer,

              ),

            ),

          ],

        ),

        const SizedBox(height:20),

        //=========================
        // DESCRIPTION
        //=========================

        CustomTextField(

          controller:
          _descriptionController,

          label:"Description",

          hintText:
          "Description",

          prefixIcon:
          Icons.description,

          maxLines:3,

        ),

        const SizedBox(height:20),

        //=========================
        // ACTIVE
        //=========================

        SwitchListTile(

          title:
          const Text("Active"),

          value:_aktif,

          onChanged:(v){

            setState((){

              _aktif=v;

            });

          },

        ),

        if(isEditing)...[

          const SizedBox(height:25),

          SizedBox(

            width:double.infinity,

            child:
            OutlinedButton.icon(

              onPressed:(){

              },

              icon:
              const Icon(Icons.delete),

              label:
              const Text("Delete"),

            ),

          ),

        ]

      ],

    ),

  ),

),
    );
  }
}