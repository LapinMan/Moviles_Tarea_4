import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';

part 'acclist_event.dart';
part 'acclist_state.dart';

class AcclistBloc extends Bloc<AcclistEvent, AcclistState> {
  AcclistBloc() : super(AcclistInitial()) {
    on<ListUpdateEvent>(_listUpdate);
  }

  void _listUpdate(ListUpdateEvent event, Emitter emit) async {
    try {
      Response? data = await _getData();
      if (data != null) {
        if (data.statusCode == 200) {
          var result = jsonDecode(data.body);
          // Esto se necesita porque el API mete toda la data dentro de un objeto con el nombre de la pagina de excel
          result = result["sheet1"];
          print(result[0]);
          // Ahora deberia estar ordenado
          emit(AcclistSuccessState(data: result));
        } else {
          emit(
            AcclistErrorState(
                errorMsg:
                    "No se pudo obtener la data, error ${data.statusCode}"),
          );
        }
      } else {
        emit(
          AcclistErrorState(errorMsg: "Respuesta fue nula"),
        );
      }
    } catch (e) {
      print(e);
      emit(
        AcclistErrorState(
            errorMsg: "Hubo algun error tratando de obtener la data"),
      );
    }
  }

  Future<Response?> _getData() async {
    try {
      final String url =
          "https://api.sheety.co/4339e61f8959ccfd71cbc189e8a1771a/tarea4Api/sheet1";
      final Response? response = await get(Uri.parse(url));
      return response != null ? response : null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
