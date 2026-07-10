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
// reinicios. En iOS el directorio temporal puede ser limpiado por el
// sistema en cualquier momento, por eso la foto "desaparecía".
// Android no se toca: sigue usando la ruta temporal tal cual la entregaba
// image_cropper.
// ---------------------------------------------------------------------------
Future<String> _persistImageIOS(String tempPath) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final ext = p.extension(tempPath).isNotEmpty ? p.extension(tempPath) : '.jpg';
  final fileName = '${const Uuid().v4()}$ext';
  final savedFile = await File(tempPath).copy(p.join(docsDir.path, fileName));
  return savedFile.path;
}

Future<String?> _pickImageFromSource(BuildContext context) async {
  final picker = ImagePicker();
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

  if (source == null) return null;

  // Solo iOS: esperamos a que termine la animación de cierre del
  // bottom sheet antes de presentar el picker nativo.
  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  if (!context.mounted) return null;

  XFile? file;
  try {
    file = await picker.pickImage(source: source!, imageQuality: 100);
    if (Platform.isIOS && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
              '[DEBUG] pickImage -> ${file == null ? "NULL" : "OK: ${file.path}"}'),
        ),
      );
    }
  } catch (e) {
    if (Platform.isIOS && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Text('[DEBUG] EXCEPCIÓN en pickImage: $e'),
        ),
      );
    }
    return null;
  }

  if (!context.mounted) return null;

  if (file == null) {
    return null;
  }

  // Mismo motivo: dar tiempo a que el picker termine de cerrarse antes
  // de presentar el cropper nativo en iOS.
  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  if (!context.mounted) return null;

  if (Platform.isIOS && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('[DEBUG] Abriendo cropImage()...'),
      ),
    );
  }

  CroppedFile? cropped;
  try {
    cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
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
    if (Platform.isIOS && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
              '[DEBUG] cropImage -> ${cropped == null ? "NULL" : "OK: ${cropped.path}"}'),
        ),
      );
    }
  } catch (e) {
    if (Platform.isIOS && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Text('[DEBUG] EXCEPCIÓN en cropImage: $e'),
        ),
      );
    }
    return null;
  }

  if (!context.mounted) return null;

  if (cropped == null) {
    return null;
  }

  // Solo iOS: persistimos la imagen en Documents. Android conserva el
  // comportamiento original (ruta temporal de image_cropper).
  String finalPath;
  if (Platform.isIOS) {
    try {
      finalPath = await _persistImageIOS(cropped.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text('[DEBUG] Imagen persistida: $finalPath'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text('[DEBUG] EXCEPCIÓN al persistir: $e'),
          ),
        );
      }
      finalPath = cropped.path;
    }
  } else {
    finalPath = cropped.path;
  }

  return finalPath;
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
        onPressed: () => _showAddTankSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo acuario'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NUEVO: funciones de nivel superior para abrir los sheets de agregar/editar.
// Se sacaron de los widgets para poder invocarlas de nuevo con datos "draft"
// después de cerrarlas y reabrirlas (ver el workaround de iOS más abajo).
// ---------------------------------------------------------------------------
void _showAddTankSheet(
  BuildContext parentContext, {
  String? initialName,
  String? initialVolume,
  DateTime? initialDate,
  String? initialImagePath,
}) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddTankSheet(
      parentContext: parentContext,
      initialName: initialName,
      initialVolume: initialVolume,
      initialDate: initialDate,
      initialImagePath: initialImagePath,
    ),
  );
}

void _showEditTankSheet(
  BuildContext parentContext,
  TankModel tank, {
  String? initialName,
  String? initialVolume,
  DateTime? initialDate,
  String? initialImagePath,
}) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _EditTankSheet(
      parentContext: parentContext,
      tank: tank,
      initialName: initialName,
      initialVolume: initialVolume,
      initialDate: initialDate,
      initialImagePath: initialImagePath,
    ),
  );
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
    _showEditTankSheet(context, widget.tank);
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
                    onPressed: _showEditSheet,
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
  // NUEVO: contexto de la pantalla padre (TanquesScreen), que sigue montado
  // aunque este sheet se cierre. Lo necesitamos para el workaround de iOS.
  final BuildContext parentContext;
  final String? initialName;
  final String? initialVolume;
  final DateTime? initialDate;
  final String? initialImagePath;

  const _AddTankSheet({
    required this.parentContext,
    this.initialName,
    this.initialVolume,
    this.initialDate,
    this.initialImagePath,
  });

  @override
  State<_AddTankSheet> createState() => _AddTankSheetState();
}

class _AddTankSheetState extends State<_AddTankSheet> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.initialName ?? '');
  late final TextEditingController _volCtrl =
      TextEditingController(text: widget.initialVolume ?? '');
  late DateTime _setupDate = widget.initialDate ?? DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _volCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // NUEVO (solo iOS): iOS 26 tiene un bug conocido (flutter/flutter#32896,
  // reaparecido en #173453) donde, al volver de la cámara/galería nativa,
  // el sistema dispara un Navigator.pop() real -no solo un toque "fantasma"
  // en la barrera- que cierra este bottom sheet mientras _pickImageFromSource
  // sigue esperando el cropper. Ese pop no se puede bloquear con
  // isDismissible/enableDrag ni con PopScope porque no pasa por un gesto
  // reconocible por Flutter.
  //
  // La única forma confiable de neutralizarlo es no dejar ningún sheet
  // abierto que el pop fantasma pueda cerrar: cerramos este formulario
  // ANTES de abrir la cámara (guardando lo que el usuario ya escribió),
  // hacemos todo el flujo de foto sobre TanquesScreen (que no tiene nada
  // debajo que perder), y al terminar reabrimos el formulario con los
  // datos guardados + la foto nueva.
  //
  // Android no se toca: sigue haciendo todo dentro del mismo sheet.
  // -------------------------------------------------------------------------
  Future<void> _pickImage() async {
    if (Platform.isIOS) {
      final draftName = _nameCtrl.text;
      final draftVolume = _volCtrl.text;
      final draftDate = _setupDate;
      final draftImagePath = _imagePath;
      final parentContext = widget.parentContext;

      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 300));

      if (!parentContext.mounted) return;

      final path = await _pickImageFromSource(parentContext);

      if (!parentContext.mounted) return;

      _showAddTankSheet(
        parentContext,
        initialName: draftName,
        initialVolume: draftVolume,
        initialDate: draftDate,
        initialImagePath: path ?? draftImagePath,
      );
      return;
    }

    final path = await _pickImageFromSource(context);
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
            _ImagePickerCard(imagePath: _imagePath, onTap: _pickImage),
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
  final BuildContext parentContext;
  final TankModel tank;
  final String? initialName;
  final String? initialVolume;
  final DateTime? initialDate;
  final String? initialImagePath;

  const _EditTankSheet({
    required this.parentContext,
    required this.tank,
    this.initialName,
    this.initialVolume,
    this.initialDate,
    this.initialImagePath,
  });

  @override
  State<_EditTankSheet> createState() => _EditTankSheetState();
}

class _EditTankSheetState extends State<_EditTankSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _volCtrl;
  late DateTime _setupDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.initialName ?? widget.tank.name);
    _volCtrl = TextEditingController(
        text: widget.initialVolume ?? widget.tank.volume.toStringAsFixed(0));
    _setupDate = widget.initialDate ?? widget.tank.setupDate;
    _imagePath = widget.initialImagePath ?? widget.tank.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _volCtrl.dispose();
    super.dispose();
  }

  // Mismo workaround que en _AddTankSheet: en iOS cerramos el sheet antes
  // de abrir la cámara para que el Navigator.pop() fantasma de iOS 26 no
  // tenga nada que cerrar, y lo reabrimos después con los datos guardados.
  Future<void> _pickImage() async {
    if (Platform.isIOS) {
      final draftName = _nameCtrl.text;
      final draftVolume = _volCtrl.text;
      final draftDate = _setupDate;
      final draftImagePath = _imagePath;
      final tank = widget.tank;
      final parentContext = widget.parentContext;

      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 300));

      if (!parentContext.mounted) return;

      final path = await _pickImageFromSource(parentContext);

      if (!parentContext.mounted) return;

      // Limpiamos la foto anterior copiada en Documents si se reemplazó.
      if (path != null && draftImagePath != null && draftImagePath != path) {
        try {
          final oldFile = File(draftImagePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (_) {
          // Si no se puede borrar, no interrumpimos el flujo del usuario.
        }
      }

      _showEditTankSheet(
        parentContext,
        tank,
        initialName: draftName,
        initialVolume: draftVolume,
        initialDate: draftDate,
        initialImagePath: path ?? draftImagePath,
      );
      return;
    }

    final path = await _pickImageFromSource(context);
    if (path == null) return;
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
            _ImagePickerCard(imagePath: _imagePath, onTap: _pickImage),
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
