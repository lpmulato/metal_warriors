# Contexto do projeto Metal Warriors

## Repositorio e versao

- Repositorio: `https://github.com/lpmulato/metal_warriors`
- Diretorio: `C:\Desenvolvimento\GAMEDEV\metal_warriors`
- Branch local: `godot_4.7.2`
- Commit local: `eae1102` (`Set Godot project version to 4.7`)
- `project.godot` declara Godot 4.7; a validacao foi feita com Godot 4.7.2.
- Godot 4.7.2 esta instalado em `C:\Desenvolvimento\GAMEDEV\Godot_v4.7.2-stable_win64.exe`.

## Publicacao da branch

A branch `godot_4.7.2` ja foi publicada com sucesso em `origin` (`lpmulato/metal_warriors`) e esta sincronizada com o commit local `eae1102`. O erro HTTP 403 relatado anteriormente foi resolvido (permissao/credencial corrigida).

## Erros observados no projeto (historico)

- Indentacao com tabs em `scripts/bullet.gd`, `scripts/robots/prometheus.gd` e `addons/PaletteSwap/PaletteGenerator.gd`: corrigida (normalizada para espacos, igual ao padrao do restante do projeto).
- `bullet.gd` tinha um bug real introduzido pela normalizacao malfeita de tabs: o `return` do `_ready()` ficou fora do `if direction == Vector2.ZERO:`, executando sempre e impedindo a conexao do sinal `body_entered`. Resultado: nenhuma bala registrava colisao (blocos destrutiveis, robos, jogadores). Corrigido restaurando a indentacao original (`return` dentro do `if`).
- `bullet.gd:explode()`: `collision_shape.disabled = true` era chamado dentro do callback `_on_body_entered`, durante o flush de fisica do Godot, causando o erro `Can't change this state while flushing queries`. Corrigido usando `collision_shape.set_deferred("disabled", true)`.
- `pilot.gd:process_shoot()`: `dict_animation_by_angle[str(cannon_angle)]` falhava porque `cannon_angle` e `float` (ex.: `45.0`), mas as chaves do dicionario sao strings sem casa decimal (`"45"`). Corrigido com `str(int(cannon_angle))`.
- Tiles fora dos limites do atlas: `TileSetAtlasSource_2a5vj` em `scenes/maps/space_station.tscn` (textura `assets/maps/space_station/240926-184325.png`, 256x104px) declarava uma grade de 16 colunas x 14 linhas (0-15, 0-13) copiada do atlas maior `TileSetAtlasSource_hwpc8`, mas a imagem so comporta 15 colunas (0-14) x 6 linhas (0-5). As linhas 6-13 e a coluna 15 apontavam para pixels fora da imagem. Confirmado por decodificacao do `tile_map_data` que a camada `Walls` (nao `DestructibleWalls`) so usa os tiles `(7,1)`, `(8,0)`, `(9,0)` desse atlas, todos dentro da area valida — as entradas fora dos limites eram sobras nao usadas. Corrigido removendo essas entradas orfas; nenhum tile visivel foi alterado.
- A Intel HD 2500 nao inicializou Vulkan/D3D12 com Godot 4.3; `--rendering-method gl_compatibility` foi usado como alternativa. A abertura grafica com Godot 4.7.2 ainda nao foi confirmada. A validacao headless neste ambiente falha com "Acesso negado" ao iniciar o `.exe` (bloqueio do ambiente da ferramenta) — precisa ser rodada manualmente pelo usuario.

## Estado local a preservar

- Arquivo temporario nao rastreado `scenes/maps/space_station.tscn517755720.tmp`: sobra do editor Godot. Nao descartar nem apagar sem confirmar que nao esta em uso.
- Este arquivo (`CONTEXTO.md`) passou a ser versionado a partir deste commit.
