package com.qifun.hddl.optionalStm;

import com.qifun.hddl.optionalStm.TArray;
import com.qifun.hddl.optionalStm.TMap;
import com.qifun.hddl.optionalStm.TSet;
import com.qifun.hddl.optionalStm.Ref;

class PlayerData
{
  public function new() {}

	var friends(default, null) = new TSet<PlayerData>();

	var lover(default, null) = new Ref<PlayerData>(null);

  var hp(default, null) = new Ref<Int>(0);

  var items(default, null) = new TArray<Item>(50);

  var skills(default, null) = new TMap<Skill, Level>();

}

typedef Level = Int;

class Skill
{

}

class Item
{
  public function new() {}

}
