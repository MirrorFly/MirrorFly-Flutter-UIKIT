
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../controllers/location_controller.dart';

class LocationSentView extends StatefulWidget{
  const LocationSentView({Key? key}) : super(key: key);

  @override
  State<LocationSentView> createState() => _LocationSentViewState();
}

class _LocationSentViewState extends State<LocationSentView> {
  var controller = Get.put(LocationController());
  @override
  void dispose() {
    Get.delete<LocationController>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
            backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          title: Text('User Location',style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
      automaticallyImplyLeading: true,
          ),
        body:SafeArea(
          child: Obx(
            ()=> Column(
              children: [
                Expanded(
                  child:GoogleMap(
                    markers: {controller.marker.value},
                      // on below line setting camera position
                      initialCameraPosition: controller.kGoogle.value,
                      // on below line we are setting markers on the map
                      //markers: Set<Marker>.of(controller.marker),
                      // on below line specifying map type.
                      mapType: MapType.normal,
                      // on below line setting user location enabled.
                      //myLocationEnabled: true,
                      // on below line setting compass enabled.
                      //compassEnabled: true,
                      // on below line specifying controller on map complete.
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController mapController)=>controller.onMapCreated(mapController),
                    onTap: (latLng)=>controller.onTap(latLng),
                    ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(
                          ()=>controller.address1.value.isNotEmpty ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Send this Location',style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor,fontSize: 14,fontWeight: FontWeight.normal),),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(controller.address1.value,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor,fontSize: 16,fontWeight: FontWeight.w700),),
                              ),
                              Text(controller.address2.value,style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor,fontSize: 14,fontWeight: FontWeight.normal),),
                            ],
                          ) : Center(child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: FloatingActionButton.small(onPressed: (){
                        if(controller.location.value.latitude!=0){
                          //sent Location Message
                          Navigator.pop(context,controller.location.value);
                          // Get.back(result: controller.location.value);
                        }
                      },
                        backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                      child: Icon(Icons.arrow_forward_rounded,color: MirrorflyUikit.getTheme?.colorOnPrimary,size: 18,),),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}