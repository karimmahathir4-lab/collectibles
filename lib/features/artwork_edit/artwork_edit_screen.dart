import '../../core/widgets/safe_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/artwork.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';

class ArtworkEditScreen extends ConsumerStatefulWidget {
  final Artwork? initialArtwork;
  const ArtworkEditScreen({super.key, this.initialArtwork});

  @override
  ConsumerState<ArtworkEditScreen> createState() => _ArtworkEditScreenState();
}

class _ArtworkEditScreenState extends ConsumerState<ArtworkEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _artworkId;
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _yearController;
  late TextEditingController _mediumController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _depthController;
  late TextEditingController _weightController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _estimatedValueController;
  late TextEditingController _sellerController;
  late TextEditingController _locationController;
  late TextEditingController _provenanceController;
  late TextEditingController _notesController;

  String? _condition;
  String _currency = 'USD';
  String? _coverPhotoPath;
  List<String> _photos = [];
  List<String> _selectedFolderIds = [];
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final a = widget.initialArtwork;
    _artworkId = a?.id ?? const Uuid().v4();
    _titleController = TextEditingController(text: a?.title ?? '');
    _artistController = TextEditingController(text: a?.artist ?? '');
    _yearController = TextEditingController(
      text: a?.yearCreated?.toString() ?? '',
    );
    _mediumController = TextEditingController(text: a?.medium ?? '');
    _widthController = TextEditingController(
      text: a?.widthCm?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: a?.heightCm?.toString() ?? '',
    );
    _depthController = TextEditingController(
      text: a?.depthCm?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: a?.weightKg?.toString() ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: a?.purchasePrice?.toString() ?? '',
    );
    _estimatedValueController = TextEditingController(
      text: a?.estimatedValue?.toString() ?? '',
    );
    _sellerController = TextEditingController(text: a?.seller ?? '');
    _locationController = TextEditingController(text: a?.location ?? '');
    _provenanceController = TextEditingController(text: a?.provenance ?? '');
    _notesController = TextEditingController(text: a?.notes ?? '');

    _condition = a?.condition ?? 'Excellent';
    _currency = a?.purchaseCurrency ?? 'USD';
    _coverPhotoPath = a?.coverPhotoPath;
    _photos = List.from(a?.photoPaths ?? []);
    _selectedFolderIds = List.from(a?.collectionIds ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _mediumController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _weightController.dispose();
    _purchasePriceController.dispose();
    _estimatedValueController.dispose();
    _sellerController.dispose();
    _locationController.dispose();
    _provenanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final saved = await ImageService.instance.saveImage(
          picked.path,
          artworkId: _artworkId,
        );
        setState(() {
          _photos.add(saved);
          _coverPhotoPath ??= saved;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add photo: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final artwork = Artwork(
      id: _artworkId,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim().isEmpty
          ? null
          : _artistController.text.trim(),
      yearCreated: int.tryParse(_yearController.text.trim()),
      medium: _mediumController.text.trim().isEmpty
          ? null
          : _mediumController.text.trim(),
      widthCm: double.tryParse(_widthController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      depthCm: double.tryParse(_depthController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      purchasePrice: double.tryParse(_purchasePriceController.text.trim()),
      purchaseCurrency: _currency,
      seller: _sellerController.text.trim().isEmpty
          ? null
          : _sellerController.text.trim(),
      estimatedValue: double.tryParse(_estimatedValueController.text.trim()),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      condition: _condition,
      provenance: _provenanceController.text.trim().isEmpty
          ? null
          : _provenanceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isFavorite: widget.initialArtwork?.isFavorite ?? false,
      coverPhotoPath:
          _coverPhotoPath ?? (_photos.isNotEmpty ? _photos.first : null),
      photoPaths: _photos,
      collectionIds: _selectedFolderIds,
      createdAt: widget.initialArtwork?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(artworksProvider.notifier).saveArtwork(artwork);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foldersAsync = ref.watch(foldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialArtwork == null
              ? 'Add Collectible'
              : 'Edit Collectible',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: TextButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(CupertinoIcons.checkmark_alt, size: 16),
                label: Text(
                  _isSaving ? 'Saving' : 'Save',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.accentWarm,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Interactive Photo Hero Strip
            _buildInteractivePhotoStrip(isDark),
            const SizedBox(height: 28),

            // Step 1: Essence
            _buildSectionLabel('Piece Essence'),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Title of the Piece *',
                hintText: 'e.g. Sculpted Terracotta Vessel',
                prefixIcon: Icon(CupertinoIcons.pencil, size: 18),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _artistController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Artist / Maker / Artisan',
                hintText: 'e.g. Hans Coper',
                prefixIcon: Icon(CupertinoIcons.person, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Year Created',
                      hintText: 'e.g. 1974',
                      prefixIcon: Icon(CupertinoIcons.calendar, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mediumController,
                    decoration: const InputDecoration(
                      labelText: 'Medium / Material',
                      hintText: 'e.g. Stoneware, Bronze',
                      prefixIcon: Icon(CupertinoIcons.paintbrush, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Step 2: Dimensions & Physical Specs
            _buildSectionLabel('Dimensions (cm) & Weight'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Width (W)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Height (H)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _depthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Depth (D)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Step 3: Valuation & Condition
            _buildSectionLabel('Valuation & Condition'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Estimated Value (\$)',
                      prefixIcon: Icon(CupertinoIcons.money_dollar, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price (\$)',
                      prefixIcon: Icon(CupertinoIcons.tag, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition Grade',
                prefixIcon: Icon(CupertinoIcons.checkmark_seal, size: 18),
              ),
              items: const [
                DropdownMenuItem(value: 'Mint', child: Text('Mint (Flawless)')),
                DropdownMenuItem(
                  value: 'Excellent',
                  child: Text('Excellent (Very minor wear)'),
                ),
                DropdownMenuItem(
                  value: 'Good',
                  child: Text('Good (Original patina)'),
                ),
                DropdownMenuItem(
                  value: 'Fair',
                  child: Text('Fair (Visible aging)'),
                ),
                DropdownMenuItem(
                  value: 'Restored',
                  child: Text('Restored (Professionally conserved)'),
                ),
              ],
              onChanged: (val) => setState(() => _condition = val),
            ),
            const SizedBox(height: 28),

            // Step 4: Organization Folders
            _buildSectionLabel('Collection Folders'),
            foldersAsync.when(
              data: (folders) {
                if (folders.isEmpty) {
                  return const Text(
                    'No folders created yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: folders.map((f) {
                    final isSel = _selectedFolderIds.contains(f.id);
                    return FilterChip(
                      selected: isSel,
                      showCheckmark: false,
                      avatar: Icon(
                        isSel
                            ? CupertinoIcons.check_mark
                            : CupertinoIcons.folder,
                        size: 14,
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      label: Text(f.name),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      selectedColor: AppTheme.accentWarm,
                      backgroundColor: isDark
                          ? AppTheme.darkSurface
                          : AppTheme.lightSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSel
                              ? AppTheme.accentWarm
                              : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFolderIds.add(f.id);
                          } else {
                            _selectedFolderIds.remove(f.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const CupertinoActivityIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),

            // Step 5: Location, Provenance & Curator Notes
            _buildSectionLabel('Provenance & Location'),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Display / Storage Location',
                hintText: 'e.g. Gallery Room, East Wall Cabinet',
                prefixIcon: Icon(CupertinoIcons.location, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _provenanceController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Provenance & Lineage',
                hintText:
                    'Acquisition history, previous collectors, certificates...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Curator Notes & Appraisals',
                hintText: 'Specific markings, signatures, observations...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppTheme.accentWarm,
        ),
      ),
    );
  }

  Widget _buildInteractivePhotoStrip(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Photographs'),
            Row(
              children: [
                _buildQuickPhotoAction(
                  icon: CupertinoIcons.camera,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildQuickPhotoAction(
                  icon: CupertinoIcons.photo,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: _photos.isEmpty
              ? GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurface
                          : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.camera_fill,
                            color: AppTheme.accentWarm.withValues(alpha: 0.8),
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add primary photograph of piece',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Capture or upload from device',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      return GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurface
                                : AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.plus,
                            color: AppTheme.accentWarm,
                          ),
                        ),
                      );
                    }

                    final path = _photos[index];
                    final isCover = _coverPhotoPath == path;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCover
                              ? AppTheme.accentWarm
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SafeImageWidget(path: path),
                          ),
                          if (isCover)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentWarm,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Cover',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photos.removeAt(index);
                                  if (_coverPhotoPath == path) {
                                    _coverPhotoPath = _photos.isNotEmpty
                                        ? _photos.first
                                        : null;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickPhotoAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.accentWarm),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
