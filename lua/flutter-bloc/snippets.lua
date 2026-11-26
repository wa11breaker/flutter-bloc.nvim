-- Bloc snippets served as LSP completion items (LSP snippet syntax).
local util = require("flutter-bloc.util")

local M = {}

local snippets = {
    -- Imports
    { "importbloc", "Import package:bloc", [[import 'package:bloc/bloc.dart';]] },
    { "importflutterbloc", "Import package:flutter_bloc", [[import 'package:flutter_bloc/flutter_bloc.dart';]] },
    { "importbloctest", "Import package:bloc_test", [[import 'package:bloc_test/bloc_test.dart';]] },

    -- Bloc and Cubit
    { "bloc", "Bloc class", [[
class ${1:Subject}Bloc extends Bloc<${1}Event, ${1}State> {
  ${1}Bloc() : super(${1}Initial()) {
    on<${1}Event>((event, emit) {
      $0
    });
  }
}]] },
    { "cubit", "Cubit class", [[
class ${1:Subject}Cubit extends Cubit<${1}State> {
  ${1}Cubit() : super(${1}Initial());
}]] },
    { "onevent", "Event handler", [[
on<${1:Event}>((event, emit) {
  $0
});]] },
    { "_onevent", "Event handler method", [[
Future<void> _on${1:Event}(
  ${1} event,
  Emitter<${2:State}> emit,
) async {
  $0
}]] },
    { "blocstate", "State class", [[class ${1:Subject}${2:Initial} extends ${1}State {}]] },
    { "blocevent", "Event class", [[class ${1:Subject}${2:Started} extends ${1}Event {}]] },
    { "blocobserver", "BlocObserver class", [[
class ${1:App}BlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}]] },

    -- Widgets
    { "blocprovider", "BlocProvider", [[
BlocProvider(
  create: (context) => ${1:Subject}${2:Bloc}(),
  child: ${0:Container()},
)]] },
    { "multiblocprovider", "MultiBlocProvider", [[
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => ${1:Subject}${2:Bloc}(),
    ),
  ],
  child: ${0:Container()},
)]] },
    { "repoprovider", "RepositoryProvider", [[
RepositoryProvider(
  create: (context) => ${1:Subject}Repository(),
  child: ${0:Container()},
)]] },
    { "multirepoprovider", "MultiRepositoryProvider", [[
MultiRepositoryProvider(
  providers: [
    RepositoryProvider(
      create: (context) => ${1:Subject}Repository(),
    ),
  ],
  child: ${0:Container()},
)]] },
    { "blocbuilder", "BlocBuilder", [[
BlocBuilder<${1:Subject}${2:Bloc}, ${1}State>(
  builder: (context, state) {
    return ${0:Container()};
  },
)]] },
    { "blocselector", "BlocSelector", [[
BlocSelector<${1:Subject}${2:Bloc}, ${1}State, ${3:SelectedState}>(
  selector: (state) {
    return ${4:state};
  },
  builder: (context, state) {
    return ${0:Container()};
  },
)]] },
    { "bloclistener", "BlocListener", [[
BlocListener<${1:Subject}${2:Bloc}, ${1}State>(
  listener: (context, state) {
    $3
  },
  child: ${0:Container()},
)]] },
    { "multibloclistener", "MultiBlocListener", [[
MultiBlocListener(
  listeners: [
    BlocListener<${1:Subject}${2:Bloc}, ${1}State>(
      listener: (context, state) {
        $3
      },
    ),
  ],
  child: ${0:Container()},
)]] },
    { "blocconsumer", "BlocConsumer", [[
BlocConsumer<${1:Subject}${2:Bloc}, ${1}State>(
  listener: (context, state) {
    $3
  },
  builder: (context, state) {
    return ${0:Container()};
  },
)]] },

    -- Lookups
    { "blocof", "BlocProvider.of", [[BlocProvider.of<${1:Subject}${2:Bloc}>(context)]] },
    { "repoof", "RepositoryProvider.of", [[RepositoryProvider.of<${1:Subject}Repository>(context)]] },
    { "read", "context.read", [[context.read<${1:Subject}${2:Bloc}>()]] },
    { "watch", "context.watch", [[context.watch<${1:Subject}${2:Bloc}>()]] },
    { "select", "context.select", [[context.select((${1:Subject}${2:Bloc} bloc) => bloc.state.${3:field})]] },

    -- Tests
    { "bloctest", "blocTest", [[
blocTest<${1:Subject}${2:Bloc}, ${1}State>(
  'emits [${3}] when ${4}.',
  build: () => ${1}${2}(),
  act: (bloc) => ${5},
  expect: () => const <${1}State>[${6}],
);]] },
    { "mockbloc", "MockBloc class", [[class Mock${1:Subject}Bloc extends MockBloc<${1}Event, ${1}State> implements ${1}Bloc {}]] },
    { "_mockbloc", "Private MockBloc class", [[class _Mock${1:Subject}Bloc extends MockBloc<${1}Event, ${1}State> implements ${1}Bloc {}]] },
    { "mockcubit", "MockCubit class", [[class Mock${1:Subject}Cubit extends MockCubit<${1}State> implements ${1}Cubit {}]] },
    { "_mockcubit", "Private MockCubit class", [[class _Mock${1:Subject}Cubit extends MockCubit<${1}State> implements ${1}Cubit {}]] },
    { "fake", "Fake class", [[class Fake${1:Subject} extends Fake implements ${1} {}]] },
    { "_fake", "Private Fake class", [[class _Fake${1:Subject} extends Fake implements ${1} {}]] },
    { "mock", "Mock class", [[class Mock${1:Subject} extends Mock implements ${1} {}]] },
    { "_mock", "Private Mock class", [[class _Mock${1:Subject} extends Mock implements ${1} {}]] },

    -- Freezed
    { "fstate", "Freezed state", [[
@freezed
sealed class ${1:Subject}State with _\$${1}State {
  const factory ${1}State.initial() = _Initial;$0
}]] },
    { "fevent", "Freezed event", [[const factory ${1:Subject}Event.${2:started}() = _${3:Started};]] },
}

local SNIPPET_KIND = vim.lsp.protocol.CompletionItemKind.Snippet
local SNIPPET_FORMAT = vim.lsp.protocol.InsertTextFormat.Snippet

function M.completion_items()
    local items = {}
    for _, s in ipairs(snippets) do
        table.insert(items, {
            label = s[1],
            kind = SNIPPET_KIND,
            detail = s[2],
            insertText = s[3],
            insertTextFormat = SNIPPET_FORMAT,
            documentation = { kind = "markdown", value = "```dart\n" .. util.snippet_preview(s[3]) .. "\n```" },
        })
    end
    return items
end

return M
