import 'package:flutter/material.dart';
import 'package:vidente_app/models/cidade.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vidente_app/services/cidade_service.dart';
import 'package:vidente_app/widgets/home.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();

  final List<Cidade> cidades;
  const Configuracoes({Key key, this.cidades}) : super(key: key);
}

class _ConfiguracoesState extends State<Configuracoes> {
  List<Cidade> cidades;

  bool carregando = false;

  @override
  void initState() {
    super.initState();
    carregarCidades();
  }

  void alterarCarregamento() {
    setState(() {
      this.carregando = !this.carregando;
    });
  }

  void carregarCidades() async {
    CidadeService service = CidadeService();
    cidades = await service.recuperarCidades();
  }

  Iterable<Cidade> filtrarCidades(String consulta) {
    return this.cidades.where(
        (cidade) => cidade.nome.toLowerCase().contains(consulta.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(16, 60, 16, 0),
        child: Column(
          children: [
            TypeAheadField<Cidade>(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: 'Procurar cidade',
                ),
              ),
              suggestionsCallback: filtrarCidades,
              onSuggestionSelected: (sugestao) {
                CidadeService service = CidadeService();
                final String filtro = sugestao.nome + ' ' + sugestao.estado;
                service.pesquisarCidade(filtro).then((cidades) {
                  this.alterarCarregamento();

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Home(),
                  ));
                });

                this.alterarCarregamento();
              },
              itemBuilder: (context, sugestao) {
                return ListTile(
                  leading: Icon(Icons.place),
                  title: Text(sugestao.nome + " - " + sugestao.siglaEstado),
                  subtitle: Text(sugestao.estado),
                );
              },
              noItemsFoundBuilder: (context) => Container(
                child: Center(
                  child: Text(
                    'Nenhuma cidade encontrada',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            this.carregando
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                : Text('')
          ],
        ),
      ),
    );
  }
}
