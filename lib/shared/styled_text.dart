import 'package:flutter/material.dart';

class StyledBody extends StatelessWidget {
  const StyledBody(
    this.text, {
    this.color = Colors.black,
    this.weight = FontWeight.bold,
    this.fontSize, // Add this line
    super.key,
  });

  final String text;
  final Color color;
  final FontWeight weight;
  final double? fontSize; // Add this line

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: weight,
            fontSize: fontSize ?? width * 0.03, // Use override if provided
          ),
    );
  }
}

class StyledBodyStrikeout extends StatelessWidget {
  const StyledBodyStrikeout(this.text,
      {this.color = Colors.grey, this.weight = FontWeight.normal, this.fontSize, super.key}); // Add fontSize parameter

  final String text;
  final Color color;
  final FontWeight weight;
  final double? fontSize; // Add this line

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.grey, // Make the strikeout grey
            decorationThickness: 1.5,     // Make the strikeout thinner
            fontSize: fontSize ?? width * 0.03, // Use custom fontSize or default
            color: color,
            fontWeight: weight,
          ),
    );
  }
}

class StyledBodyCenter extends StatelessWidget {
  const StyledBodyCenter(this.text,
      {this.color = Colors.black, this.weight = FontWeight.bold, super.key});

  final String text;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: width * 0.03,
            color: color,
            fontWeight: weight,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class StyledHeading extends StatelessWidget {
  const StyledHeading(
    this.text, {
    this.color = Colors.black,
    this.weight = FontWeight.bold,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.fontSize, // Add this line
    super.key,
  });

  final String text;
  final Color? color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize; // Add this line

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: fontSize ?? width * 0.04, // Use override if provided
            color: color,
            fontWeight: weight,
          ),
    );
  }
}

class StyledTitle extends StatelessWidget {
  const StyledTitle(this.text,
      {this.color = Colors.black, this.weight = FontWeight.bold, super.key});

  final String text;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: width * 0.05,
            color: color,
            fontWeight: weight,
          ),
    );
  }
}

class StyledBodyPlayFair extends StatelessWidget {
  const StyledBodyPlayFair(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class StyledHeadingPlayFair extends StatelessWidget {
  const StyledHeadingPlayFair(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class StyledTitlePlayFair extends StatelessWidget {
  const StyledTitlePlayFair(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
