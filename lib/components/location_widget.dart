import 'package:agro_k/components/primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// ignore: depend_on_referenced_packages
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as user_location;

class LocationWidget extends StatefulWidget {
  final Function(LatLng)? onLocationConfirmed;
  final LatLng? initialLocation;
  final bool isPinned;

  const LocationWidget(
      {Key? key, this.onLocationConfirmed, this.initialLocation, this.isPinned = false})
      : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  Marker? marker;
  late GoogleMapController googleMapController;
  var defaultInitialCameraLatitude = 37.43296265331129;
  var defaultFinalCameraLatitude = -122.08832357078792;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null && widget.isPinned) {
      marker = Marker(markerId: const MarkerId("0"), position: widget.initialLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        initialCameraPosition: CameraPosition(
            bearing: 0.0,
            target: LatLng(
                widget.initialLocation?.latitude ?? defaultInitialCameraLatitude,
                widget.initialLocation?.longitude ?? defaultFinalCameraLatitude),
            tilt: 0.0,
            zoom: 19.151926040649414),
        markers: marker != null ? {marker!} : {},
        mapType: MapType.hybrid,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        onTap: (LatLng position) async {
          if (widget.onLocationConfirmed != null) {
            if (kIsWeb) {
              marker = null;
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 250));
            }
            if (mounted) {
              setState(() {
                marker =
                    Marker(markerId: const MarkerId("0"), position: position);
              });
            }
          }
        },
        buildingsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.onLocationConfirmed != null && !kIsWeb ? Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: PrimaryButton(
                  onPressed: showSearchDialog, title: "Search", type: PrimaryButtonType.filled, actionType: PrimaryButtonActionType.positive,),
            ) : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: PrimaryButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  }, title: "Cancel", type: PrimaryButtonType.filled, actionType: PrimaryButtonActionType.negative,),
            ),
            widget.onLocationConfirmed != null ? Visibility(
                visible: marker != null,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: PrimaryButton(
                      onPressed: () {
                        widget.onLocationConfirmed!(marker!.position);
                        Navigator.of(context).pop();
                      },
                      title: "Confirm", type: PrimaryButtonType.filled, actionType: PrimaryButtonActionType.positive,),
                )) : Container()
          ],
        ),
      )
    ]);
  }

  Future<void> showSearchDialog() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: "AIzaSyCqvV43wWkjrzfDEV7hSzjRUJjOnGRsMWQ",
        mode: Mode.overlay,
        language: "en",
        types: const [""],
        components: [Component(Component.country, "usa")],
        strictbounds: false,
        onError: (PlacesAutocompleteResponse response) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Error with Google Places ${response.errorMessage}",
            ),
            backgroundColor: Colors.red,
          ));
        });

    displayPrediction(p);
  }

  void displayPrediction(Prediction? p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyCqvV43wWkjrzfDEV7hSzjRUJjOnGRsMWQ",
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    if (p?.placeId != null) {
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p!.placeId!);
      var lat = detail.result.geometry!.location.lat;
      var lng = detail.result.geometry!.location.lng;
      var latLng = LatLng(lat, lng);
      googleMapController
          .animateCamera(CameraUpdate.newLatLngZoom(latLng, 14.0));
      setState(() {
        marker = Marker(
            markerId: const MarkerId("0"),
            position: latLng,
            infoWindow: InfoWindow(title: detail.result.name));
      });
    }
  }

  Future<LatLng> getSingleLocation() async {
    user_location.Location location = user_location.Location();
    bool serviceEnabled;
    user_location.PermissionStatus permissionGranted;
    user_location.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error("Permisos rechazados");
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == user_location.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != user_location.PermissionStatus.granted) {
        return Future.error("Permisos rechazados");
      }
    }
    locationData = await location.getLocation();
    if (locationData.latitude != null &&
        locationData.longitude != null &&
        locationData.altitude != null) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    } else {
      return Future.error("Location no tiene todos los valores necesarios");
    }
  }
}
