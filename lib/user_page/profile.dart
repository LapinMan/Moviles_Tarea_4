import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'bloc/acclist_bloc.dart';
import 'bloc/picture_bloc.dart';
import 'circular_button.dart';
import 'cuenta_item.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _imageFile;

  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  void initState() {
    _subscription =
        Connectivity().onConnectivityChanged.listen((connectivityResult) {
      print(connectivityResult);
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
          _is_there_connectivity(true);
          break;

        case ConnectivityResult.none:
          _is_there_connectivity(false);
          break;
        default:
          break;
      }
    });
    super.initState();
  }

  void _is_there_connectivity(bool conn) {
    if (conn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Conectando a la red...",
            ),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "No hay conexion a la red",
            ),
          ),
        );
    }
  }

  Future _captureAndShare() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    print(tempDir);
    String tempPath = tempDir.path;
    print(tempPath);

    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);

        /// Share Plugin
        await Share.shareFiles([imagePath.path]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            DescribedFeatureOverlay(
              featureId: "fd_screenshot",
              tapTarget: const Icon(Icons.share),
              title: Text("Compartir Pantalla"),
              description: Text("Toma foto a la pantalla y deja compartirla"),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                tooltip: "Compartir pantalla",
                onPressed: () async {
                  await _captureAndShare();
                },
                icon: Icon(Icons.share),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlocConsumer<PictureBloc, PictureState>(
                  listener: (context, state) {
                    if (state is PictureErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${state.errorMsg}"),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is PictureSelectedState) {
                      return CircleAvatar(
                        backgroundImage: FileImage(state.picture),
                        minRadius: 40,
                        maxRadius: 80,
                      );
                    } else if (state is PictureErrorState) {
                      return CircleAvatar(
                        backgroundColor: Colors.red,
                        minRadius: 40,
                        maxRadius: 80,
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: Colors.grey,
                        minRadius: 40,
                        maxRadius: 80,
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Bienvenido",
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text("Usuario${UniqueKey()}"),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DescribedFeatureOverlay(
                      featureId: "fd_tarjeta",
                      tapTarget: const Icon(Icons.credit_card),
                      title: Text("Mostrar Tarjetas"),
                      description: Text(
                          "Este boton sirve para mostrar las tarjetas de credito"),
                      backgroundColor: Theme.of(context).primaryColor,
                      targetColor: Colors.white,
                      textColor: Colors.white,
                      contentLocation: ContentLocation.above,
                      overflowMode: OverflowMode.extendBackground,
                      child: CircularButton(
                        textAction: "Ver tarjeta",
                        iconData: Icons.credit_card,
                        bgColor: Color(0xff123b5e),
                        action: null,
                      ),
                    ),
                    DescribedFeatureOverlay(
                      featureId: "fd_foto",
                      tapTarget: const Icon(Icons.camera_alt),
                      title: Text("Tomar Foto"),
                      description: Text("Cambia la foto usando la camara"),
                      backgroundColor: Theme.of(context).primaryColor,
                      targetColor: Colors.white,
                      textColor: Colors.white,
                      child: CircularButton(
                        textAction: "Cambiar foto",
                        iconData: Icons.camera_alt,
                        bgColor: Colors.orange,
                        action: () {
                          BlocProvider.of<PictureBloc>(context).add(
                            ChangeImageEvent(),
                          );
                        },
                      ),
                    ),
                    DescribedFeatureOverlay(
                      featureId: "fd_tutorial",
                      tapTarget: const Icon(Icons.play_arrow_outlined),
                      title: Text("Tutorial"),
                      description: Text("Pos ya andas viendo que hace esto"),
                      backgroundColor: Theme.of(context).primaryColor,
                      targetColor: Colors.white,
                      textColor: Colors.white,
                      child: CircularButton(
                        textAction: "Ver tutorial",
                        iconData: Icons.play_arrow,
                        bgColor: Colors.green,
                        action: () {
                          FeatureDiscovery.discoverFeatures(
                            context,
                            const <String>{
                              // Feature ids for every feature that you want to showcase in order.
                              "fd_tarjeta", "fd_foto", "fd_tutorial",
                              "fd_screenshot"
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48),
                BlocConsumer<AcclistBloc, AcclistState>(
                  listener: (context, state) {
                    if (state is AcclistInitial) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Cargando lista..."),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AcclistSuccessState) {
                      return OnSuccessList((state.data as List));
                    } else if (state is AcclistErrorState) {
                      return OnFailedList();
                    } else {
                      return OnLoadingList();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // widgets para la Imagen

  // Widgets para la lista
  Container OnLoadingList() {
    return Container(
      height: 140,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Container OnSuccessList(List<Object?> data) {
    return Container(
      height: 140,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return CuentaItem(
            data: data[index],
          );
        },
      ),
    );
  }

  Container OnFailedList() {
    return Container(
      height: 140,
      child: Text("No se pudieron cargar los datos"),
    );
  }
}
