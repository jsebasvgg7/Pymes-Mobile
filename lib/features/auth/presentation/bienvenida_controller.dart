import '../../../core/storage/session_storage.dart';

class BienvenidaController {
  BienvenidaController({required this._almacen});

  final SessionStorage _almacen;

  bool _vista = false;

  bool get vista => _vista;

  Future<void> cargar() async {
    _vista = await _almacen.bienvenidaVista();
  }

  Future<void> marcarVista() async {
    _vista = true;
    await _almacen.marcarBienvenidaVista();
  }
}
