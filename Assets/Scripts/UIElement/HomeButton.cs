﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomeButton : MonoBehaviour {

	public void OnClick () {
		UIManager.Instance.IsHomeActive = !UIManager.Instance.IsHomeActive;
	}
}
