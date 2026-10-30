import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon App',
      home: PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  TextEditingController nameController = TextEditingController();

  Pokemon? pokemon;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchPokemon() async {
    if (isLoading) {
      return;
    }

    String name = nameController.text.trim().toLowerCase();

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a Pokemon name.';
        pokemon = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      pokemon = null;
    });

    try {
      var url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data['name'] != null &&
            data['id'] != null) {
          setState(() {
            pokemon = Pokemon.fromJson(data);
          });
        } else {
          setState(() {
            errorMessage = 'The data received is not valid.';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage =
              'Pokemon not found. Please check the name and try again.';
        });
      } else {
        setState(() {
          errorMessage = 'Server error. Status code: ${response.statusCode}';
        });
      }
    } on FormatException {
      setState(() {
        errorMessage = 'The data received is not valid.';
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Could not connect. Please check your internet connection.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon App'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter Pokemon name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : fetchPokemon,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage != '')
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (pokemon != null) showPokemonInfo(),
          ],
        ),
      ),
    );
  }

  Widget showPokemonInfo() {
    Pokemon p = pokemon!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.frontImage != null)
          Center(
            child: Image.network(
              p.frontImage!,
              height: 150,
            ),
          ),
        const SizedBox(height: 20),
        Text(p.name.toUpperCase(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text('Basic Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('ID: ${p.id}'),
        Text('Base Experience: ${p.baseExperience}'),
        Text('Height: ${p.height / 10} m'),
        Text('Weight: ${p.weight / 10} kg'),
        const SizedBox(height: 20),
        Text('Types',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(p.types.join(', ')),
        const SizedBox(height: 20),
        Text('Abilities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        for (String ability in p.abilities) Text('- $ability'),
        const SizedBox(height: 20),
        Text('Moves (${p.moves.length})',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        for (String move in p.moves) Text('- $move'),
      ],
    );
  }
}
