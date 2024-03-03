local bloc = {}
local util = require("flutter-bloc.util")

bloc.create_bloc_template = function(bloc_name)
    local snake_case_name = util.camel_to_snake(bloc_name)

    local template = string.format(
        [[
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '%s_event.dart';
part '%s_state.dart';

class %sBloc extends Bloc<%sEvent, %sState> {
  %sBloc() : super(%sInitial()) {
    on<%sEvent>((event, state) {
      // TODO: Implement event handler
    });
  }
}
]],
        snake_case_name,
        snake_case_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name
    )

    return template
end

bloc.create_event_template = function(bloc_name)
    local snake_case_name = util.camel_to_snake(bloc_name)

    local template = string.format(
        [[
part of '%s_bloc.dart';

sealed class %sEvent extends Equatable {
  const %sEvent();

  @override
  List<Object> get props => [];
}
]],
        snake_case_name,
        bloc_name,
        bloc_name
    )

    return template
end

bloc.create_bloc_state_template = function(bloc_name)
    local snake_case_name = util.camel_to_snake(bloc_name)

    local template = string.format(
        [[
part of '%s_bloc.dart';

sealed class %sState extends Equatable {
  const %sState();

  @override
  List<Object> get props => [];
}

final class %sInitial extends %sState {}
]],
        snake_case_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name
    )

    return template
end


-- Cubit templates
bloc.create_cubit_template = function(bloc_name)
    local snake_case_name = util.camel_to_snake(bloc_name)

    local template = string.format(
        [[
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '%s_state.dart';

class %sCubit extends Cubit<%sState> {
  %sCubit() : super(%sInitial());
}
]],
        snake_case_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name
    )

    return template
end

bloc.create_cubit_state_template = function(bloc_name)
    local snake_case_name = util.camel_to_snake(bloc_name)

    local template = string.format(
        [[
part of '%s_cubit.dart';

sealed class %sState extends Equatable {
  const %sState();

  @override
  List<Object> get props => [];
}

final class %sInitial extends %sState {}
]],
        snake_case_name,
        bloc_name,
        bloc_name,
        bloc_name,
        bloc_name
    )

    return template
end


return bloc
