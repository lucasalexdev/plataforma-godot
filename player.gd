extends CharacterBody2D
# ------------------------------------------------------------
# Script do personagem (Player) para jogo de plataforma 2D.
# Totalmente comentado em PT-BR para facilitar o entendimento.
#
# PRÉ-REQUISITOS NA CENA:
# - Nó CharacterBody2D chamado "Player" (este script está nele).
# - Um Sprite2D como filho do Player (para enxergar o personagem).
# - Um CollisionShape2D como filho do Player (retângulo, 32x32 por ex.).
# - Um chão feito com StaticBody2D + CollisionShape2D.
#
# PRÉ-REQUISITOS DE CONTROLES:
# - No Mapa de Entrada, atribuir teclas às ações:
#   ui_left  (A ou seta esquerda)
#   ui_right (D ou seta direita)
#   ui_accept (Barra de espaço)  -> pulo
# ------------------------------------------------------------

# ===== Parâmetros de movimento =====
const VELOCIDADE := 200.0     # Velocidade horizontal (pixels por segundo)
const FORCA_PULO := -420.0    # Força do pulo (negativo porque sobe no eixo Y)
const GRAVIDADE := 1000.0     # Gravidade (pixels por segundo²)
const ATRITO := 1800.0        # Quão rápido o player "freia" quando solta a tecla

func _physics_process(delta: float) -> void:
	# 1) Aplicar gravidade quando NÃO está no chão.
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	else:
		# Garante que não acumule valores residuais de queda quando pousa.
		# (opcional: deixa o pulo mais "seco")
		velocity.y = min(velocity.y, 0.0)

	# 2) Ler entrada horizontal usando as ações padrão do Godot.
	#    get_axis retorna:
	#    -1 quando ui_left está pressionado,
	#     1 quando ui_right está pressionado,
	#     0 quando nenhuma/ambas (cancelando).
	var direcao := Input.get_axis("ui_left", "ui_right")

	if direcao != 0:
		# Há entrada: define velocidade x diretamente.
		velocity.x = direcao * VELOCIDADE
	else:
		# Sem entrada: aplicar "atrito" para parar suavemente.
		# move_toward move o valor atual em direção a um alvo (0) a uma taxa por segundo.
		velocity.x = move_toward(velocity.x, 0.0, ATRITO * delta)

	# 3) Pulo: só permite se está tocando o chão.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = FORCA_PULO

	# 4) Mover e resolver colisões.
	#    move_and_slide lida com escorregar em superfícies e detectar chão.
	move_and_slide()

	# 5) (Opcional) Virar o sprite para a direção do movimento.
	#    Se você tiver um Sprite2D filho chamado "Sprite2D", vamos espelhar no eixo X.
	if has_node("Sprite2D"):
		var spr: Sprite2D = $Sprite2D
		if velocity.x != 0:
			spr.flip_h = velocity.x < 0
