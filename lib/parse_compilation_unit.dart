import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/string_source.dart';

//TODO(xha): supprimer ces méthodes et utiliser les version du analyzer
// lorsque le paramètre parseGenericMethods ne sera plus nécessaire
CompilationUnit parseCompilationUnitWorkaround(String contents,
    {String name, bool suppressErrors: false, bool parseFunctionBodies: true}) {
  Source source = new StringSource(contents, name);
  return _parseSource(contents, source,
      suppressErrors: suppressErrors, parseFunctionBodies: parseFunctionBodies);
}

CompilationUnit _parseSource(String contents, Source source,
    {bool suppressErrors: false, bool parseFunctionBodies: true}) {
  var reader = new CharSequenceReader(contents);
  var errorCollector = new _ErrorCollector();
  var scanner = new Scanner(source, reader, errorCollector);
  var token = scanner.tokenize();
  var parser = new Parser(source, errorCollector)
    ..parseFunctionBodies = parseFunctionBodies
    ..parseGenericMethods = true;
  var unit = parser.parseCompilationUnit(token)
    ..lineInfo = new LineInfo(scanner.lineStarts);

  if (errorCollector.hasErrors && !suppressErrors) throw errorCollector.group;

  return unit;
}

/// A simple error listener that collects errors into an [AnalyzerErrorGroup].
class _ErrorCollector extends AnalysisErrorListener {
  final _errors = <AnalysisError>[];

  _ErrorCollector();

  /// The group of errors collected.
  AnalyzerErrorGroup get group =>
      new AnalyzerErrorGroup.fromAnalysisErrors(_errors);

  /// Whether any errors where collected.
  bool get hasErrors => !_errors.isEmpty;

  @override
  void onError(AnalysisError error) => _errors.add(error);
}
