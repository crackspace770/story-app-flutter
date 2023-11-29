import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../provider/location_provider.dart';
import '../provider/upload_provider.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as location;

class UploadPage extends StatefulWidget {
  final Function() onAddAction;
  final Function() onMap;
  final double latitude;
  final double longitude;

  const UploadPage({
    super.key, required this.onAddAction,
    required this.onMap,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final location.Location _location = location.Location();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
        actions: [
          IconButton(
            onPressed: () => _onUpload(),
            icon: context.watch<UploadProvider>().isUploading
                ? const CircularProgressIndicator(
              color: Colors.white,
            )
                :const Icon(Icons.upload),
            tooltip: "Upload",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: context.watch<UploadProvider>().imagePath == null
                  ? const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.image,
                  size: 100,
                ),
              )
                  : _showImage(
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.red, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                controller: descriptionController,
                minLines: 6,
                maxLines: null,
                onSaved: (String? val) {
                  descriptionController.text = val ?? '';
                },
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Consumer<LocationProvider>(
              builder: (context, provider, child) {
                if (provider.selectedLocation != null) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    addressController.text =
                        provider.selectedLocation.toString();
                  });
                } else {
                  debugPrint(addressController.text);
                }
                return Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Address',
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.transparent,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.red, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your location.';
                      }
                      return null;
                    },
                    controller: addressController,
                    onTap: () {
                      widget.onMap();
                    },
                  ),
                );
              },
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () => _onGalleryView(),
                    child: const Text("Gallery"),
                  ),

                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () => _onCameraView(),
                    child: const Text("Camera"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState =
    ScaffoldMessenger.of(context);

    final uploadProvider = context.read<UploadProvider>();

    final homeProvider = context.read<UploadProvider>();
    final imagePath = homeProvider.imagePath;
    final imageFile = homeProvider.imageFile;
    if (imagePath == null || imageFile == null) return;

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();
    final newBytes = await uploadProvider.compressImage(bytes);

    await uploadProvider.upload(
      newBytes,
      fileName,
      descriptionController.text,
      lat: widget.latitude, // Use the latitude from the widget parameter
      lon: widget.longitude, // Use the longitude from the widget parameter
    );

    if (uploadProvider.uploadResponse != null) {
      homeProvider.setImageFile(null);
      homeProvider.setImagePath(null);
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(uploadProvider.message),
      ),
    );
    widget.onAddAction();
  }

  _onGalleryView() async {
    final provider = context.read<UploadProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }

  }

  _onCameraView() async {
    final provider = context.read<UploadProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }

  }



  Widget _showImage() {
    /// todo-show-01: change widget to show the image
    final imagePath = context.read<UploadProvider>().imagePath;
    return kIsWeb
        ? Image.network(
      imagePath.toString(),
      fit: BoxFit.contain,
    )
        : Image.file(
      File(imagePath.toString()),
      fit: BoxFit.contain,
    );
  }
}
