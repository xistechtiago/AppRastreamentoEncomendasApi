library ml;

import 'package:rastreamento_encomendas/model/objeto_rastreio.dart';
import 'package:rastreamento_encomendas/model/objeto_rastreio.dart';
import 'package:http/http.dart' as http;

/// api mercadolivre
class FlutterMercadoLivre {

  /// Returna o andamento do rastreio.
  Future<ObjetoRastreio?> fazerRastreio({required String codRastreio}) async {
    ObjetoRastreio? retorno;
    try {
      final response = await http.get(
          Uri.parse("https://api.postmon.com.br/v1/rastreio/ect/$codRastreio"),
          headers: {"Content-Type": "text/json; charset=utf-8"});
      if (response.statusCode == 200) {
        retorno = ObjetoRastreio(response.body);
      } else {
        print("Erro na requisição");
      }
      return retorno;
    } catch (e) {
      print(e);
    }
    return retorno;
  }
}
