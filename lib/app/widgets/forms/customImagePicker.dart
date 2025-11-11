import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatelessWidget {
  final VoidCallback onPickImage;
  final XFile? selectedImage;
  final String buttonText;
  final String? Function()? validator;

  const CustomImagePicker({
    Key? key,
    required this.onPickImage,
    required this.selectedImage,
    this.buttonText = 'Seleccionar imagen',
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (selectedImage != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900, // Color de la sombra
                  blurRadius: 8, // Difuminado de la sombra
                  offset: Offset(0, 4), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  selectedImage!.path,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        else
          Center(
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'No hay imagen seleccionada',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20), // Espacio entre la imagen y el botón
        Center(
          child: ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.image, color: Colors.white),
            label: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: Colors.blue.shade900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (validator != null)
          Center(
            child: Text(
              validator!() ?? '',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}