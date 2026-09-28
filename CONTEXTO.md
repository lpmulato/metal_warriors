# Contexto do projeto Metal Warriors

## Repositorio e versao

- Repositorio: `https://github.com/lpmulato/metal_warriors`
- Diretorio: `C:\Desenvolvimento\GAMEDEV\metal_warriors`
- Branch local: `godot_4.7.2`
- Branch publicada: `godot_4.7.2` (`origin` sincronizado com as alteracoes desta entrega)
- `project.godot` declara Godot 4.7; a validacao foi feita com Godot 4.7.2.
- Godot 4.7.2 esta instalado em `C:\Desenvolvimento\GAMEDEV\Godot_v4.7.2-stable_win64.exe`.

## Publicacao da branch

A branch `godot_4.7.2` e publicada em `origin` (`lpmulato/metal_warriors`) e recebe as alteracoes desta entrega. O erro HTTP 403 relatado anteriormente foi resolvido (permissao/credencial corrigida).

## Tela inicial, controles e pausa

- `project.godot` inicia em `scenes/ui/start_menu.tscn`; a tela permite escolher 2, 3 ou 4 jogadores e selecionar Automático, Teclado ou um controle por jogador.
- A fase com 2 jogadores usa tela dividida horizontal (P1 em cima, P2 embaixo); com 3 ou 4, usa quatro quadrantes. Cada câmera acompanha seu piloto. P3 e P4 são criados no piso inferior, abaixo dos pontos iniciais de P1 e P2; todos compartilham uma instância do mapa.
- `scripts/game_input.gd` cria actions separadas para P1-P4. Em modo automático, os controles conectados são atribuídos em ordem às vagas de P1 a P4; vagas sem controle usam o teclado.
- `scripts/abstract/playable.gd`, `scripts/abstract/robot.gd`, `scripts/pilot.gd` e os scripts dos robos usam as actions da vaga do piloto (`input_slot` de 1 a 4). O campo `id` permanece separado para preservar a cor/material existente.
- Durante a fase, Esc abre/fecha o menu pausado; Enter abre o menu. Enter no botao focado "Retomar" volta ao jogo.
- O usuário confirmou que a tela inicial apareceu e funcionou ao iniciar o jogo. A pausa por Esc/Enter e a detecção/atribuição dos controles ainda precisam de teste manual. Menu, cena e configuração de 2, 3 e 4 jogadores foram validados em modo headless com Godot 4.7.2, incluindo visibilidade dos viewports, alvos das câmeras e posições iniciais de P3/P4; a apresentação gráfica ainda precisa de teste manual.
- A implementação atual de multiplayer e suas atualizações de documentação estão modificadas localmente e ainda não foram commitadas ou publicadas.

## Erros observados no projeto (historico)

- Indentacao com tabs em `scripts/bullet.gd`, `scripts/robots/prometheus.gd` e `addons/PaletteSwap/PaletteGenerator.gd`: corrigida (normalizada para espacos, igual ao padrao do restante do projeto).
- `bullet.gd` tinha um bug real introduzido pela normalizacao malfeita de tabs: o `return` do `_ready()` ficou fora do `if direction == Vector2.ZERO:`, executando sempre e impedindo a conexao do sinal `body_entered`. Resultado: nenhuma bala registrava colisao (blocos destrutiveis, robos, jogadores). Corrigido restaurando a indentacao original (`return` dentro do `if`).
- `bullet.gd:explode()`: `collision_shape.disabled = true` era chamado dentro do callback `_on_body_entered`, durante o flush de fisica do Godot, causando o erro `Can't change this state while flushing queries`. Corrigido usando `collision_shape.set_deferred("disabled", true)`.
- `pilot.gd:process_shoot()`: `dict_animation_by_angle[str(cannon_angle)]` falhava porque `cannon_angle` e `float` (ex.: `45.0`), mas as chaves do dicionario sao strings sem casa decimal (`"45"`). Corrigido com `str(int(cannon_angle))`.
- Tiles fora dos limites do atlas: `TileSetAtlasSource_2a5vj` em `scenes/maps/space_station.tscn` (textura `assets/maps/space_station/240926-184325.png`, 256x104px) declarava uma grade de 16 colunas x 14 linhas (0-15, 0-13) copiada do atlas maior `TileSetAtlasSource_hwpc8`, mas a imagem so comporta 15 colunas (0-14) x 6 linhas (0-5). As linhas 6-13 e a coluna 15 apontavam para pixels fora da imagem. Confirmado por decodificacao do `tile_map_data` que a camada `Walls` (nao `DestructibleWalls`) so usa os tiles `(7,1)`, `(8,0)`, `(9,0)` desse atlas, todos dentro da area valida — as entradas fora dos limites eram sobras nao usadas. Corrigido removendo essas entradas orfas; nenhum tile visivel foi alterado.
- A Intel HD 2500 nao inicializou Vulkan/D3D12 com Godot 4.3; `--rendering-method gl_compatibility` foi usado como alternativa. A abertura grafica com Godot 4.7.2 ainda nao foi confirmada. A validação headless atual com Godot 4.7.2 funciona; a falha de inicialização headless mencionada no histórico foi superada.

## Estado local a preservar

- Arquivo temporario nao rastreado `scenes/maps/space_station.tscn517755720.tmp`: sobra do editor Godot. Nao descartar nem apagar sem confirmar que nao esta em uso.
- Este arquivo (`CONTEXTO.md`) foi versionado e e mantido junto com as alteracoes do projeto.
- Visao detalhada da arquitetura, cenas, nodes, scripts e fluxos: `docs/ARQUITETURA_E_FUNCIONAMENTO.md`.
