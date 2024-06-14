import 'package:flutter/material.dart';

void main() {
  runApp(Formulario());
}

class Formulario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulário',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaginaPrincipal(),
    );
  }
}

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();
  double _skillLevel = 50;
  String? _selectedPosition;

  final List<String> _positions = [
    'Goleiro',
    'LD',
    'LE',
    'ZAG',
    'VOL',
    'MC',
    'ATA'
  ];

  List<Map<String, dynamic>> _submittedData = [];

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submittedData.add({
          'name': _nameController.text,
          'team': _teamController.text,
          'skill': _skillLevel.toString(),
          'position': _selectedPosition!,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados salvos com sucesso')),
      );
      _nameController.clear();
      _teamController.clear();
      setState(() {
        _skillLevel = 50;
        _selectedPosition = null;
      });
    }
  }

  void _navigateToDetailsScreen(BuildContext context) {
    if (_submittedData.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaDeDetalhes(
            submittedData: _submittedData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum dado para mostrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cadastro de Jogadores',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _teamController,
                decoration: InputDecoration(labelText: 'Time de Futebol'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: InputDecoration(labelText: 'Posição'),
                items: _positions.map((String position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPosition = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma posição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Habilidade: ${_skillLevel.round()}'),
              Slider(
                value: _skillLevel,
                min: 50,
                max: 100,
                divisions: 50,
                label: _skillLevel.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _skillLevel = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToDetailsScreen(context),
                child: Text('Ver Dados'),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    super.dispose();
  }
}

class TelaDeDetalhes extends StatefulWidget {
  final List<Map<String, dynamic>> submittedData;

  TelaDeDetalhes({required this.submittedData});

  @override
  _TelaDeDetalhesState createState() => _TelaDeDetalhesState();
}

class _TelaDeDetalhesState extends State<TelaDeDetalhes> {
  final _filterController = TextEditingController();
  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = widget.submittedData;
    _filterController.addListener(_filterData);
  }

  void _filterData() {
    setState(() {
      _filteredData = widget.submittedData.where((data) {
        return data['name']!
            .toLowerCase()
            .contains(_filterController.text.toLowerCase());
      }).toList();
    });
  }

  void _deleteData(int index) {
    setState(() {
      _filteredData.removeAt(index);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Jogador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Filtrar por Nome',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  final data = _filteredData[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nome: ${data['name']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteData(index),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Time: ${data['team']}',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Habilidade: ${data['skill']}',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Posição: ${data['position']}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}