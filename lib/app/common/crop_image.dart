import 'dart:io';
import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../mirrorfly_uikit_plugin.dart';
class CropImage extends StatefulWidget {
  const CropImage({Key? key, required this.imageFile}) : super(key: key);
  final File imageFile;

  // File? _file;
  // File? _sample;
  // File? _lastCropped;
  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  late CustomImageCropController controller;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              // padding: const EdgeInsets.all(20.0),
              child: CustomImageCrop(
                cropController: controller,
                shape: CustomCropShape.Square,
                image: FileImage(widget.imageFile),
              ),
              /*child: Crop.file(
                imageFile,
                key: cropKey,
                aspectRatio: 5.0 / 5.0,
              ),*/
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: ()=>Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: MirrorflyUikit.getTheme?.secondaryColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    child: Text("CANCEL",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor,fontSize:16.0),),
                  ),
                ),
                /*SizedBox(width: 1.0,),
                Material(child: IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => controller.addTransition(CropImageData(scale: 1.33))),),
                SizedBox(width: 1.0,),
                Material(child: IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => controller.addTransition(CropImageData(scale: 0.75))),),*/
                const SizedBox(width: 1.0,),
                Material(color: MirrorflyUikit.getTheme?.secondaryColor,child: IconButton(onPressed: ()=>controller.addTransition(CropImageData(angle: -pi / 4)), icon: Icon(Icons.rotate_left, color: MirrorflyUikit.getTheme?.textPrimaryColor,))),
                const SizedBox(width: 1.0,),
                Material(color: MirrorflyUikit.getTheme?.secondaryColor,child: IconButton(onPressed: ()=>controller.addTransition(CropImageData(angle: pi / 4)), icon: Icon(Icons.rotate_right, color: MirrorflyUikit.getTheme?.textPrimaryColor,))),
                const SizedBox(width: 1.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Helper.showLoading(message: "Image Cropping...", buildContext: context);
                      await controller.onCropImage().then((image){
                        Helper.hideLoading(context: context);
                        // Get.back(result: image);
                        Navigator.pop(context, image);
                      });

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: MirrorflyUikit.getTheme?.secondaryColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    child: Text("SAVE",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor,fontSize:16.0),),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  // Future<void> _cropImage() async {
    /*final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file!,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

    debugPrint('$file');*/
  // }
}