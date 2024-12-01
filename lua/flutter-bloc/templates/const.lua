local M = {}

M.default_bloc_template = [[
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(${pascalCaseBlocName}Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]

M.equatalbe_bloc_template = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(${pascalCaseBlocName}Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]
M.freezed_bloc_template = [[
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';
part '${snakeCaseBlocName}_bloc.freezed.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(_Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]

M.default_bloc_state = [[
part of '${snakeCaseBlocName}_bloc.dart';

@immutable
${classPrefix} class ${pascalCaseBlocName}State {}

${subclassPrefix}class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
]]

M.equatalbe_bloc_state = [[
part of '${snakeCaseBlocName}_bloc.dart';

${classPrefix} class ${pascalCaseBlocName}State extends Equatable {
    const ${pascalCaseBlocName}State();

    @override
    List<Object> get props => [];
}

${subclassPrefix}class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
]]

M.freezed_bloc_state = [[
part of '${snakeCaseBlocName}_bloc.dart';

@freezed
class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
    const factory ${pascalCaseBlocName}.initial() = _Initial;
}
]]

M.default_bloc_event = [[
part of '${snakeCaseBlocName}_bloc.dart';

@immutable
${classPrefix} class ${pascalCaseBlocName}Event {}
]]

M.equatable_bloc_event = [[
part of '${snakeCaseBlocName}_bloc.dart';

${classPrefix} class ${pascalCaseBlocName}Event extends Equatable {
    const ${pascalCaseBlocName}Event();

    @override
    List<Object> get props => [];
}
]]

M.freezed_bloc_event = [[
part of '${snakeCaseBlocName}_bloc.dart';

${classPrefix} class ${pascalCaseBlocName}State extends Equatable {
    const ${pascalCaseBlocName}State();

    @override
    List<Object> get props => [];
}

${subclassPrefix}class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
]]

return M
