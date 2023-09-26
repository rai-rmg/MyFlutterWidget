import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Form Example'),
        ),
        body: const DynamicFormPage(),
      ),
    );
  }
}

List<Map<String, dynamic>> getFormFields() {
  return [
    {
      'id': 1,
      'question': 'Quelle est votre nom',
      'answer_type': 'text',
      'answer_format': "",
      'answer_available_values': 'any',
    },
    {
      'id': 2,
      'question': 'Quelle est votre prénom :',
      'answer_type': 'text',
      'answer_format': "",
      'answer_available_values': 'any',
    },
    {
      'id': 3,
      'question': 'Quelle est votre adresse : ',
      'answer_type': 'text',
      'answer_format': "",
      'answer_available_values': 'any',
    },
    {
      'id': 4,
      'question': 'Code postal : ',
      'answer_type': 'text',
      'answer_format': '',
      'answer_available_values': 'any',
    },
    {
      'id': 5,
      'question': 'sexe :',
      'answer_type': 'radio',
      'answer_format': '',
      'answer_available_values': [
        {'label': 'Homme', 'value': 'Homme'},
        {'label': 'Femme', 'value': 'Femme'},
      ],
    },
    {
      'id': 6,
      'question': 'dans quel situation êtes-vous ? :',
      'answer_type': 'select',
      'answer_format': '',
      'answer_available_values': [
        {'label': '1', 'value': 'Divorcé'},
        {'label': '2', 'value': 'Marié'},
        {'label': '3', 'value': 'Celibataire'},
        {'label': '4', 'value': 'Veuf'},
      ],
    },
    {
      'id': 7,
      'question': 'acceptez vous les conditions ? :',
      'answer_type': 'boolean',
      'answer_format': '',
      'answer_available_values': 'oui',
    }
  ];
}

class DynamicFormPage extends StatelessWidget {
  const DynamicFormPage({super.key});

    void handleFormSubmit(String formData, BuildContext context) {
    // Vous pouvez traiter les données du formulaire ici
    // Au lieu d'imprimer, affichez-les dans une boîte de dialogue
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Données du formulaire'),
          content: Text(formData.toString()), // Convertir les données en chaîne
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DynamicFormWidget(
              height: 350.0, width: 600.0, formFields: getFormFields(),
              onSubmit: (formData) => handleFormSubmit(formData, context)),
        ],
      ),
    );
  }
}

class DynamicFormWidget extends StatefulWidget {
  final List<Map<String, dynamic>> formFields;
  final double? width;
  final double? height;
  final Function(String formData) onSubmit; // Déclaration de la callback


  const DynamicFormWidget(
      {super.key, required this.formFields, required this.width, required this.height,
      required this.onSubmit});

  @override
  _DynamicFormWidgetState createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 400,
      height: widget.height ?? 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Utilisez le défilement vertical
        physics:
           const AlwaysScrollableScrollPhysics(), // Autorisez le défilement même si le contenu s'adapte
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...widget.formFields.map((field) {
                final id = field['id'].toString();
                final question = field['question'] as String;
                final answerType = field['answer_type'] as String;
                final answerFormat = field['answer_format'] as String;

                Widget inputWidget = const Text('Initial Widget');
                if (answerType == 'text') {
                  inputWidget = TextFormField(
                    decoration: InputDecoration(labelText: question),
                    validator: (value) {
                      final regexp = RegExp(answerFormat);
                      if (value == null || !regexp.hasMatch(value)) {
                        return 'Format invalide';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _formData[id] = value;
                    },
                  );
                } else if (answerType == 'radio') {
                  // Gérer le champ de type radio
                  final radioOptions =
                      field['answer_available_values'] as List<dynamic>;

                  inputWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: radioOptions.map((option) {
                      final radioLabel = option['label']!;
                      final radioValue = option['value']!;
                      return Row(
                        children: [
                          Radio(
                            value: radioValue,
                            groupValue: _formData[id],
                            onChanged: (value) {
                              setState(() {
                                _formData[id] = value;
                              });
                            },
                          ),
                          Text(radioLabel),
                        ],
                      );
                    }).toList(),
                  );
                } else if (answerType == 'select') {
                  final selectOptions =
                      field['answer_available_values'] as List<dynamic>;

                  inputWidget = SingleChildScrollView(
                    child: DropdownButtonFormField<String>(
                      value: _formData[id],
                      items:
                          selectOptions.map<DropdownMenuItem<String>>((option) {
                        final selectLabel = option['value']!;
                        final selectValue = option['label']!;
                        return DropdownMenuItem<String>(
                          value: selectValue,
                          child: Text(selectLabel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _formData[id] = value;
                        });
                      },
                      decoration: InputDecoration(labelText: question),
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une option';
                        }
                        return null;
                      },
                    ),
                  );
                } else if (answerType == 'boolean') {
                  final checkboxOptions =
                      field['answer_available_values'] as String;

                  inputWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...checkboxOptions.split(' ou ').map<Widget>((option) {
                        return Row(
                          children: [
                            Checkbox(
                              value: _formData[id]?.contains(option) ?? false,
                              onChanged: (value) {
                                setState(() {
                                  if (_formData[id] == null) {
                                    _formData[id] = [];
                                  }
                                  if (value == true) {
                                    _formData[id]!.add(option);
                                  } else {
                                    _formData[id]!.remove(option);
                                  }
                                });
                              },
                            ),
                            Text(option),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                } else {
                  // Type de champ non pris en charge
                  inputWidget = const Text('Type de champ non pris en charge');
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: inputWidget,
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final jsonString = jsonEncode(_formData);
                    widget.onSubmit(jsonString); // Appel de la callback avec les données du formulaire
                  }
                },
                child: const Text('Submit'),
              ), // Fin du bouton Submit
            ], // Fin de la colonne des champs
          ), // Fin du formulaire
        ), // Fin du widget Form
      ), // Fin du widget SingleChildScrollView
    ); // Fin du widget Container
  }
} // Fin du widget DynamicFormWidget

