import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/pet_species.dart';
import '../../providers/pet_provider.dart';
import '../settings/legal_information_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  String _selectedSpecies = PetSpecies.cat;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose your companion',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: PetSpecies.all
                    .map((s) => _speciesOption(s))
                    .toList(),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet name',
                  hintText: 'Give them a name...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onStart,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text('Start'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LegalInformationScreen(),
                  ),
                ),
                child: const Text(
                  'Privacy: all data stays on this device. Read the privacy policy and terms.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStart() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give them a name')),
      );
      return;
    }
    ref.read(petProvider.notifier).createPet(name, _selectedSpecies);
  }

  Widget _speciesOption(String species) {
    final selected = _selectedSpecies == species;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose ${PetSpecies.emoji(species)} $species',
      child: GestureDetector(
        onTap: () => setState(() => _selectedSpecies = species),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFB870).withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFFFFB870) : Colors.white24,
              width: 2,
            ),
          ),
          child: Text(
            PetSpecies.emoji(species),
            style: const TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }
}
