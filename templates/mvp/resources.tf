resource "anypoint_bg" "bgs" {
  count = length(local.bgs_list)

  name = element(local.bgs_list, count.index).name
  parentorganizationid = var.root_org
  ownerid = lookup(local.data_users_map, element(local.bgs_list, count.index).owner_username).id
  entitlements_createsuborgs = element(local.bgs_list, count.index).create_suborgs
  entitlements_createenvironments = element(local.bgs_list, count.index).create_env
  entitlements_globaldeployment = element(local.bgs_list, count.index).global_deployment
  entitlements_vcoresproduction_assigned = element(local.bgs_list, count.index).vcores_prod
  entitlements_vcoressandbox_assigned = element(local.bgs_list, count.index).vcores_sandbox
  entitlements_vcoresdesign_assigned = element(local.bgs_list, count.index).vcores_design
  entitlements_staticips_assigned = element(local.bgs_list, count.index).static_ips
  entitlements_vpcs_assigned = element(local.bgs_list, count.index).vpcs
  entitlements_loadbalancer_assigned = element(local.bgs_list, count.index).lbs
  entitlements_vpns_assigned = element(local.bgs_list, count.index).vpns
}

resource "anypoint_env" "envs" {
  count = length(local.envs_list)

  org_id = lookup(local.data_bg_map, element(local.envs_list, count.index).bg_name).id
  name = element(local.envs_list, count.index).name
  type = element(local.envs_list, count.index).type
}


resource "anypoint_user" "users" {
  count = length(local.users_list)

  org_id = var.root_org
  username = element(local.users_list, count.index).username
  first_name = element(local.users_list, count.index).firstname
  last_name = element(local.users_list, count.index).lastname
  email = element(local.users_list, count.index).email
  phone_number = element(local.users_list, count.index).phone
  password = element(local.users_list, count.index).pwd
}


resource "anypoint_team" "lvl1_teams" {
  count = length(local.teams_lvl1_list)

  org_id = var.root_org
  parent_team_id = var.root_team
  team_name = element(local.teams_lvl1_list, count.index).name
  team_type = element(local.teams_lvl1_list, count.index).type
}

resource "anypoint_team" "lvl2_teams" {
  count = length(local.teams_lvl2_list)

  org_id = var.root_org
  parent_team_id = lookup(local.data_teams_lvl1_map, element(local.teams_lvl2_list, count.index).parent_team_name, {id: ""}).id
  team_name = element(local.teams_lvl2_list, count.index).name
  team_type = element(local.teams_lvl2_list, count.index).type
}


resource "anypoint_team_roles" "lvl1_teams_roles" {
  count = length(local.teams_lvl1_list)

  org_id = var.root_org
  team_id = anypoint_team.lvl1_teams[count.index].id
  
  dynamic "roles" {
    for_each = [
      for role in local.teams_lvl1_roles_list : role
      if role.team_name == anypoint_team.lvl1_teams[count.index].team_name
    ]
    content {
      role_id = element([
        for iter in local.data_roles_list : iter.role_id
        if iter.name == roles.value.name
      ], 0)
      context_params = {
        org = lookup(local.data_bg_map, roles.value["context_org_name"]).id
        envId = length(roles.value["context_env_name"]) > 0 ? element(lookup(local.data_envs_map, "${roles.value.context_org_name}:${roles.value.context_env_name}"),0).id : null
      }
    }
  }
}
resource "anypoint_team_roles" "lvl2_teams_roles" {
  count = length(local.teams_lvl2_list)

  org_id = var.root_org
  team_id = anypoint_team.lvl2_teams[count.index].id
  
  dynamic "roles" {
    for_each = [
      for role in local.teams_lvl2_roles_list : role
      if role.team_name == anypoint_team.lvl2_teams[count.index].team_name
    ]
    content {
      role_id = element([
        for iter in local.data_roles_list : iter.role_id
        if iter.name == roles.value.name
      ], 0)
      context_params = {
        org = lookup(local.data_bg_map, roles.value["context_org_name"]).id
        envId = length(roles.value["context_env_name"]) > 0 ? element(lookup(local.data_envs_map, "${roles.value.context_org_name}:${roles.value.context_env_name}"), 0).id : null
      }
    }
  }
}


resource "anypoint_team_member" "lvl1_teams_members" {
  count = length(local.teams_lvl1_members_list)

  org_id = var.root_org
  team_id = lookup(local.data_teams_lvl1_map,element(local.teams_lvl1_members_list, count.index).team_name).team_id
  user_id = lookup(local.data_users_map, element(local.teams_lvl1_members_list, count.index).user_name).id
}
resource "anypoint_team_member" "lvl2_teams_members" {
  count = length(local.teams_lvl2_members_list)

  org_id = var.root_org
  team_id = lookup(local.data_teams_lvl2_map, element(local.teams_lvl2_members_list, count.index).team_name).team_id
  user_id = lookup(local.data_users_map, element(local.teams_lvl2_members_list, count.index).user_name).id
}
