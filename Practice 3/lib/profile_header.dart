import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.university,
    super.key,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(72),
        child: SizedBox.square(
          dimension: 144,
          child: Transform.scale(
            scale: 1.8,
            alignment: Alignment.topCenter,
            child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        name,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(
        university,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}
