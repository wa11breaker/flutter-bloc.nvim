-- Placeholders: {{name}} (PascalCase), {{file}} (snake_case), {{kind}} ("bloc"/"cubit"),
-- {{class_modifier}} ("sealed"/"abstract"), {{subclass_modifier}} ("final "/"")
local M = {}

M.bloc = {
    default = [[
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '{{file}}_event.dart';
part '{{file}}_state.dart';

class {{name}}Bloc extends Bloc<{{name}}Event, {{name}}State> {
  {{name}}Bloc() : super({{name}}Initial()) {
    on<{{name}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]],

    equatable = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{file}}_event.dart';
part '{{file}}_state.dart';

class {{name}}Bloc extends Bloc<{{name}}Event, {{name}}State> {
  {{name}}Bloc() : super({{name}}Initial()) {
    on<{{name}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]],

    freezed = [[
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{file}}_event.dart';
part '{{file}}_state.dart';
part '{{file}}_bloc.freezed.dart';

class {{name}}Bloc extends Bloc<{{name}}Event, {{name}}State> {
  {{name}}Bloc() : super(_Initial()) {
    on<{{name}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]],
}

M.cubit = {
    default = [[
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '{{file}}_state.dart';

class {{name}}Cubit extends Cubit<{{name}}State> {
  {{name}}Cubit() : super({{name}}Initial());
}
]],

    equatable = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{file}}_state.dart';

class {{name}}Cubit extends Cubit<{{name}}State> {
  {{name}}Cubit() : super({{name}}Initial());
}
]],

    freezed = [[
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{file}}_state.dart';
part '{{file}}_cubit.freezed.dart';

class {{name}}Cubit extends Cubit<{{name}}State> {
  {{name}}Cubit() : super(_Initial());
}
]],
}

M.state = {
    default = [[
part of '{{file}}_{{kind}}.dart';

@immutable
{{class_modifier}} class {{name}}State {}

{{subclass_modifier}}class {{name}}Initial extends {{name}}State {}
]],

    equatable = [[
part of '{{file}}_{{kind}}.dart';

{{class_modifier}} class {{name}}State extends Equatable {
  const {{name}}State();

  @override
  List<Object?> get props => [];
}

{{subclass_modifier}}class {{name}}Initial extends {{name}}State {}
]],

    freezed = [[
part of '{{file}}_{{kind}}.dart';

@freezed
{{class_modifier}} class {{name}}State with _${{name}}State {
  const factory {{name}}State.initial() = _Initial;
}
]],
}

M.event = {
    default = [[
part of '{{file}}_bloc.dart';

@immutable
{{class_modifier}} class {{name}}Event {}
]],

    equatable = [[
part of '{{file}}_bloc.dart';

{{class_modifier}} class {{name}}Event extends Equatable {
  const {{name}}Event();

  @override
  List<Object?> get props => [];
}
]],

    freezed = [[
part of '{{file}}_bloc.dart';

@freezed
{{class_modifier}} class {{name}}Event with _${{name}}Event {
  const factory {{name}}Event.started() = _Started;
}
]],
}

return M
