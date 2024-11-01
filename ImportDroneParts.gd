@tool
extends EditorScenePostImport


func _post_import(scene):
    if scene == null:
        print("Scene is empty.")
        return
    if scene is Frame:
        for node in scene.get_children():
            if node is MeshInstance3D:
                var node_name = node.name
                if node_name.ends_with("-colbox"):
                    var shape = collision_shape(node, "box")
                    shape.name = node_name.replace("-colbox", "-col")
                    scene.add_child(shape)
                    shape.set_owner(scene)
                    node.queue_free()
                    continue
                elif node_name.ends_with("-colcylinder"):
                    var shape = collision_shape(node, "cylinder")
                    shape.name = node_name.replace("-colcylinder", "-col")
                    scene.add_child(shape)
                    shape.set_owner(scene)
                    node.queue_free()
                    continue
                for child in node.get_children():
                    var child_name = child.name
                    if child is StaticBody3D:
                        for coll in child.get_children():
                            child.remove_child(coll)
                            scene.add_child(coll)
                            coll.set_owner(scene)
                            coll.transform = child.transform
                            coll.name = child_name + "-col"
                        child.queue_free()
                    elif child is MeshInstance3D:
                        if child_name.ends_with("-colbox"):
                            var shape = collision_shape(child, "box")
                            shape.name = child_name.replace("-colbox", "-col")
                            scene.add_child(shape)
                            shape.set_owner(scene)
                        elif child_name.ends_with("-colcylinder"):
                            var shape = collision_shape(child, "cylinder")
                            shape.name = child_name.replace(
                                "-colcylinder", "-col")
                            scene.add_child(shape)
                            shape.set_owner(scene)
                        child.queue_free()

    elif scene is Propeller:
        if scene.get_child_count() != 4:
            print("Error: Expected 4 nodes: CW, CCW, PropDisk-cylinder, PropBlurDisk.")
            return scene
        var scene_checks = [false, false, false]
        var children = scene.get_children()
        for node in children:
            var collision = null
            if node is MeshInstance3D:
                if node.name == "CW" and scene_checks[0] == false:
                    scene_checks[0] = true
                elif node.name == "CCW" and scene_checks[1] == false:
                    scene_checks[1] = true
                elif node.name.ends_with("-cylinder") and scene_checks[2] == false:
                    scene_checks[2] = true
                    collision = node
                    var area = Area3D.new()
                    scene.add_child(area)
                    area.set_owner(scene)
                    area.name = "Area3D"
                    var shape = collision_shape(collision, "cylinder")
                    area.add_child(shape)
                    shape.set_owner(scene)
                    shape.name = collision.name.replace("-colcylinder", "-col")
                    collision.queue_free()
                else:
                    # PropBlurDisk
                    var mat = node.mesh.surface_get_material(0) as StandardMaterial3D
                    mat.flags_transparent = true
                    var disk_shader = load("res://drone/parts/propellers/PropBlurShader.tres") as Shader
                    var disk_mat = ShaderMaterial.new()
                    disk_mat.gdshader = disk_shader
# var blur_texture = load("res://Assets/Drone/Parts/Propellers/prop_blur_disk.png") as Texture
# disk_shader.set_default_texture_param("prop_blur_texture", blur_texture)
                    var blur_texture = mat.albedo_texture
                    disk_mat.set_shader_parameter("prop_blur", blur_texture)
                    disk_mat.set_shader_parameter("alpha_boost", 1)
                    node.mesh.surface_set_material(0, disk_mat)
        var mat = children[0].mesh.surface_get_material(0) as StandardMaterial3D
        var prop_shader = load("res://drone/parts/propellers/PropellerShader.tres") as Shader
        var prop_mat = ShaderMaterial.new()
        prop_mat.gdshader = prop_shader
        for i in range(2):
            children[i].mesh.surface_set_material(0, prop_mat)

        if scene_checks != [true, true, true]:
            print("Error reading scene %s" % [scene])
            return scene

        var raycast = RayCast3D.new()
        raycast.name = "RayCast3D"
        raycast.target_position = Vector3.DOWN
        raycast.exclude_parent = true
        scene.add_child(raycast)
        raycast.set_owner(scene)

    elif scene is Motor:
        for node in scene.get_children():
            var node_name = node.name
            if node_name.ends_with("-colcylinder"):
                var area = Area3D.new()
                scene.add_child(area)
                area.set_owner(scene)
                area.name = "Area3D"
                var shape = collision_shape(node, "cylinder")
                area.add_child(shape)
                shape.set_owner(scene)
                shape.name = node.name.replace("-colcylinder", "-col")
                node.queue_free()

    return scene


func collision_shape(node: MeshInstance3D, shape: String):
    var collision = CollisionShape3D.new()
    match shape:
        "box":
            var collision_shape = BoxShape3D.new()
            collision_shape.extents = node.scale
            collision.shape = collision_shape
        "cylinder":
            var collision_shape = CylinderShape3D.new()
            collision_shape.radius = node.scale.x
            collision_shape.height = node.scale.y * 2.0
            collision.shape = collision_shape
        "mesh":
            var collision_shape = ConvexPolygonShape3D.new()
            collision_shape.points = node.mesh.get_faces()
            collision.shape = collision_shape
        _:
            return

    collision.transform = node.transform
    collision.scale = Vector3.ONE
    return collision
