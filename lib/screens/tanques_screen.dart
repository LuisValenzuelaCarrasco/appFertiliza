import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/tank_model.dart';
import '../models/tank_provider.dart';
import 'home_screen.dart';
import 'package:rutina_fertiliza/widgets/fertiliza_app_bar.dart';

class _FullScreenImage extends StatelessWidget {
  final String imagePath;
  const _FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 1.0,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: Center(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NUEVO (solo iOS): copia la imagen recortada desde el directorio temporal
// hacia el directorio de Documents de la app, que sí persiste entre
// reinicios.
// ---------------------------------------------------------------------------
Future<String> _persistImageIOS(String tempPath) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final ext = p.extension(tempPath).isNotEmpty ? p.extension(tempPath) : '.jpg';
  final fileName = '${const Uuid().v4()}$ext';
  final savedFile = await File(tempPath).copy(p.join(docsDir.path, fileName));
  return savedFile.path;
}

void _debugSnack(BuildContext context, String msg) {
  if (!Platform.isIOS || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        duration: const Duration(seconds: 4), content: Text('[DEBUG] $msg')),
  );
}

const CropAspectRatio _kCropAspectRatio =
    CropAspectRatio(ratioX: 16, ratioY: 9);

Future<CroppedFile?> _openCropper(String sourcePath) {
  return ImageCropper().cropImage(
    sourcePath: sourcePath,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 100,
    aspectRatio: _kCropAspectRatio,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Ajustar imagen',
        toolbarColor: const Color(0xFF1B5E20),
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: const Color(0xFF4CAF50),
        statusBarColor: const Color(0xFF1B5E20),
        backgroundColor: Colors.black,
        initAspectRatio: CropAspectRatioPreset.ratio16x9,
        lockAspectRatio: false,
        hideBottomControls: true,
      ),
      IOSUiSettings(
        title: 'Ajustar imagen',
        aspectRatioLockEnabled: false,
        resetAspectRatioEnabled: false,
        aspectRatioPickerButtonHidden: true,
        rotateButtonsHidden: true,
        rotateClockwiseButtonHidden: true,
        cancelButtonTitle: 'Cancelar',
        doneButtonTitle: 'Listo',
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Toma/elige una imagen de la fuente indicada, la recorta y (en iOS) la
// persiste en Documents. NO abre ningún modal adicional de Flutter: el
// picker nativo y el cropper nativo se presentan directamente sobre lo que
// esté en pantalla (incluido un showModalBottomSheet ya abierto), sin
// necesidad de cerrarlo. Esto evita el bug de iOS 26 que impide apilar dos
// modales *de Flutter* uno sobre otro.
// ---------------------------------------------------------------------------
Future<String?> _captureImage(BuildContext context, ImageSource source) async {
  final picker = ImagePicker();

  _debugSnack(context, 'source elegido = $source');

  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 400));
  }
  if (!context.mounted) return null;

  XFile? file;
  try {
    file = await picker.pickImage(source: source, imageQuality: 100);
    _debugSnack(
        context, 'pickImage -> ${file == null ? "NULL" : "OK: ${file.path}"}');
  } catch (e) {
    _debugSnack(context, 'EXCEPCIÓN en pickImage: $e');
    return null;
  }

  if (!context.mounted) return null;
  if (file == null) return null;

  if (Platform.isIOS) {
    // Margen para que el UIImagePickerController termine de cerrarse antes
    // de presentar el cropper; si no, iOS puede rechazar la presentación y
    // el cropper devuelve NULL sin lanzar excepción.
    await Future.delayed(const Duration(milliseconds: 700));
  }
  if (!context.mounted) return null;

  _debugSnack(context, 'Abriendo cropImage()...');

  CroppedFile? cropped;
  try {
    cropped = await _openCropper(file.path);
    _debugSnack(context,
        'cropImage (intento 1) -> ${cropped == null ? "NULL" : "OK: ${cropped.path}"}');

    if (cropped == null && Platform.isIOS) {
      _debugSnack(context,
          'cropImage devolvió NULL (probable conflicto de transición). Reintentando...');
      await Future.delayed(const Duration(milliseconds: 700));
      if (!context.mounted) return null;
      cropped = await _openCropper(file.path);
      _debugSnack(context,
          'cropImage (intento 2) -> ${cropped == null ? "NULL" : "OK: ${cropped.path}"}');
    }
  } catch (e) {
    _debugSnack(context, 'EXCEPCIÓN en cropImage: $e');
    return null;
  }

  if (!context.mounted) return null;
  if (cropped == null) return null;

  String finalPath;
  if (Platform.isIOS) {
    try {
      finalPath = await _persistImageIOS(cropped.path);
      _debugSnack(context, 'Imagen persistida: $finalPath');
      _debugSnack(context,
          '¿existe el archivo persistido? ${await File(finalPath).exists()}');
    } catch (e) {
      _debugSnack(context, 'EXCEPCIÓN al persistir: $e');
      finalPath = cropped.path;
    }
  } else {
    finalPath = cropped.path;
  }

  _debugSnack(context, 'captureImage -> devolviendo: $finalPath');
  return finalPath;
}

// ---------------------------------------------------------------------------
// Usado por Android: abre el chooser (cámara/galería) como un
// showModalBottomSheet propio y luego captura. En Android nunca hay un
// sheet padre abierto al mismo tiempo, así que apilar este modal no tiene
// el problema de iOS. NO TOCAR este flujo para Android.
// ---------------------------------------------------------------------------
Future<String?> _pickImageFromSource(BuildContext context) async {
  ImageSource? source;

  if (!context.mounted) return null;

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1A5276)),
              title: const Text('Tomar foto'),
              onTap: () {
                source = ImageSource.camera;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF1A5276)),
              title: const Text('Elegir de galería'),
              onTap: () {
                source = ImageSource.gallery;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );

  if (source == null) {
    _debugSnack(context, 'source elegido = NULL (usuario cerró el chooser)');
    return null;
  }

  return _captureImage(context, source!);
}

class TanquesScreen extends StatelessWidget {
  const TanquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TankProvider>();
    final tanks = provider.tanks;

    return Scaffold(
      appBar: const FertilizaAppBar(
        titulo: 'FERTILIZA ®',
        subtitulo: 'Mis Acuarios',
      ),
      body: Column(
        children: [
          Expanded(
            child: tanks.isEmpty
                ? const Center(
                    child: Text(
                      'No tienes acuarios.\n¡Agrega uno con el botón +!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: tanks.length,
                    itemBuilder: (context, index) {
                      final tank = tanks[index];
                      return _TankCard(tank: tank);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo acuario'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddTankSheet(),
    );
  }
}

class _TankCard extends StatefulWidget {
  final TankModel tank;
  const _TankCard({required this.tank});

  @override
  State<_TankCard> createState() => _TankCardState();
}

class _TankCardState extends State<_TankCard> {
  void _openFullScreenImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullScreenImage(imagePath: imagePath)),
    );
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditTankSheet(tank: widget.tank),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tank = widget.tank;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(tank: tank)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: tank.imagePath != null &&
                          File(tank.imagePath!).existsSync()
                      ? Image.file(
                          File(tank.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color:
                                const Color(0xFF5DADE2).withValues(alpha: 0.15),
                            child: const Icon(Icons.broken_image,
                                size: 56, color: Color(0xFF1A5276)),
                          ),
                        )
                      : Container(
                          color:
                              const Color(0xFF5DADE2).withValues(alpha: 0.15),
                          child: const Icon(Icons.water,
                              size: 56, color: Color(0xFF1A5276)),
                        ),
                ),
                if (tank.imagePath != null &&
                    File(tank.imagePath!).existsSync())
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => _openFullScreenImage(tank.imagePath!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Ver imagen',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tank.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(tank.volumeLabel,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF1A5276))),
                        const SizedBox(height: 4),
                        Text('Día ${tank.daysSinceSetup}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF1A5276)),
                    onPressed: () => _showEditSheet(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        context.read<TankProvider>().deleteTank(tank.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTankSheet extends StatefulWidget {
  const _AddTankSheet();

  @override
  State<_AddTankSheet> createState() => _AddTankSheetState();
}

class _AddTankSheetState extends State<_AddTankSheet> {
  final _nameCtrl = TextEditingController();
  final _volCtrl = TextEditingController();
  DateTime _setupDate = DateTime.now();
  String? _imagePath;

  // Controla si mostramos el selector de fuente (cámara/galería) inline,
  // dentro del propio sheet, en vez de abrir un segundo modal de Flutter.
  bool _choosingSource = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _volCtrl.dispose();
    super.dispose();
  }

  void _pickImage() {
    if (Platform.isIOS) {
      // En iOS mostramos el elegidor DENTRO del sheet (sin abrir otro
      // modal), para no chocar con el bug de iOS 26 de modales apilados.
      setState(() => _choosingSource = true);
      return;
    }

    // Android: comportamiento intacto, sin cambios.
    _pickImageFromSource(context).then((path) {
      if (!mounted) return;
      if (path != null) setState(() => _imagePath = path);
    });
  }

  Future<void> _captureFromSource(ImageSource source) async {
    setState(() => _choosingSource = false);
    final path = await _captureImage(context, source);
    if (!mounted) return;
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _setupDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _setupDate = picked);
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _volCtrl.text.trim().isEmpty) return;

    final tank = TankModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      volume: double.tryParse(_volCtrl.text) ?? 0,
      setupDate: _setupDate,
      imagePath: _imagePath,
    );

    context.read<TankProvider>().addTank(tank);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(tank: tank)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottom + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nuevo acuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _choosingSource
                ? _InlineSourceChooser(
                    onCamera: () => _captureFromSource(ImageSource.camera),
                    onGallery: () => _captureFromSource(ImageSource.gallery),
                    onCancel: () => setState(() => _choosingSource = false),
                  )
                : _ImagePickerCard(imagePath: _imagePath, onTap: _pickImage),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del acuario',
                prefixIcon: Icon(Icons.water),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _volCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Litros (Reales) descontando decoracion)',
                prefixIcon: Icon(Icons.water_drop),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF1A5276)),
              title: Text(
                  'Fecha de inicio: ${_setupDate.day}/${_setupDate.month}/${_setupDate.year}'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Crear acuario'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EditTankSheet extends StatefulWidget {
  final TankModel tank;
  const _EditTankSheet({required this.tank});

  @override
  State<_EditTankSheet> createState() => _EditTankSheetState();
}

class _EditTankSheetState extends State<_EditTankSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _volCtrl;
  late DateTime _setupDate;
  String? _imagePath;

  bool _choosingSource = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tank.name);
    _volCtrl =
        TextEditingController(text: widget.tank.volume.toStringAsFixed(0));
    _setupDate = widget.tank.setupDate;
    _imagePath = widget.tank.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _volCtrl.dispose();
    super.dispose();
  }

  void _pickImage() {
    if (Platform.isIOS) {
      setState(() => _choosingSource = true);
      return;
    }

    // Android: comportamiento intacto, sin cambios.
    _pickImageFromSource(context).then((path) {
      if (!mounted) return;
      if (path != null) setState(() => _imagePath = path);
    });
  }

  Future<void> _captureFromSource(ImageSource source) async {
    setState(() => _choosingSource = false);
    final oldPath = _imagePath;
    final path = await _captureImage(context, source);
    if (!mounted) return;
    if (path == null) return;

    if (Platform.isIOS && oldPath != null && oldPath != path) {
      try {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _imagePath = path);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _setupDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _setupDate = picked);
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _volCtrl.text.trim().isEmpty) return;

    final updated = widget.tank.copyWith(
      name: _nameCtrl.text.trim(),
      volume: double.tryParse(_volCtrl.text) ?? widget.tank.volume,
      setupDate: _setupDate,
      imagePath: _imagePath,
    );

    context.read<TankProvider>().updateTank(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottom + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Editar acuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _choosingSource
                ? _InlineSourceChooser(
                    onCamera: () => _captureFromSource(ImageSource.camera),
                    onGallery: () => _captureFromSource(ImageSource.gallery),
                    onCancel: () => setState(() => _choosingSource = false),
                  )
                : _ImagePickerCard(imagePath: _imagePath, onTap: _pickImage),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del acuario',
                prefixIcon: Icon(Icons.water),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _volCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Volumen (litros)',
                prefixIcon: Icon(Icons.water_drop),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF1A5276)),
              title: Text(
                  'Fecha de inicio: ${_setupDate.day}/${_setupDate.month}/${_setupDate.year}'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selector de fuente (cámara/galería) mostrado INLINE dentro del sheet, sin
// abrir ningún modal adicional de Flutter. Reemplaza temporalmente a
// _ImagePickerCard mientras _choosingSource es true.
// ---------------------------------------------------------------------------
class _InlineSourceChooser extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onCancel;

  const _InlineSourceChooser({
    required this.onCamera,
    required this.onGallery,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onCamera,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 32, color: Color(0xFF1A5276)),
                      SizedBox(height: 8),
                      Text('Tomar foto',
                          style: TextStyle(color: Color(0xFF1A5276))),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 100, color: Colors.grey.shade400),
              Expanded(
                child: InkWell(
                  onTap: onGallery,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library,
                          size: 32, color: Color(0xFF1A5276)),
                      SizedBox(height: 8),
                      Text('Galería',
                          style: TextStyle(color: Color(0xFF1A5276))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ImagePickerCard({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
          image: imagePath != null
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                  onError: (_, __) {
                    // Ayuda a detectar si la ruta apuntaba a un archivo que
                    // ya no existe en el momento de renderizar.
                  },
                )
              : null,
        ),
        child: imagePath == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Agregar foto', style: TextStyle(color: Colors.grey)),
                ],
              )
            : Stack(
                children: [
                  const SizedBox.expand(),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
