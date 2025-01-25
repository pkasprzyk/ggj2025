extends Node
# global singleton CONFIG

var config : GameplayConfig = load("res://config/gameplay.tres")

func change_bubble_types_active() -> bool : return config.change_type
func change_bubble_types_period() -> float : return config.change_type_period

func unit_stats_hp() -> float : return config.units_hp
func unit_stats_base_damage() -> float : return config.base_damage
func unit_stats_reduced_damage() -> float : return config.reduced_damage
func unit_stats_shoot_cooldown_s() -> float: return 3.0

func points_goal() -> float : return config.points_goal
func points_per_spawn() -> float : return config.points_per_spawn
func points_per_kill() -> float : return config.points_per_kill
func points_for_base_hit() -> float : return config.points_for_base_hit

func get_power_up_cooldown_s() -> float: return 5.0
func get_power_up_duration_s() -> float: return 1.0
func get_power_up_speed_mult() -> float: return 5.0
func get_power_up_shoot_mult() -> float: return 5.0
