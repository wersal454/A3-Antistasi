class A3A_BlackMarketDialog : A3A_TabbedDialogBlackmarket
{
  idd = A3A_IDD_BLACKMARKETVEHICLEDIALOG;
  onLoad = "['onLoad'] spawn A3A_fnc_blackMarketDialog";
  onUnload = "['onUnload'] spawn A3A_fnc_blackMarketDialog";

    class Controls
    {
        class TitlebarText : A3A_TitlebarText
        {
            idc = -1;
            text = $STR_trader_black_market_title;
            x = DIALOG_X;
            y = DIALOG_Y - 10 * GRID_H;
            w = DIALOG_W * GRID_W;
            h = 5 * GRID_H;
        };

        class TipText : A3A_TitlebarText
        {
          idc = -1;
          text = $STR_antistasi_dialogs_black_market_tip;
          font = A3A_NOTIFICATION_FONT;
          x = DIALOG_X;
          y = DIALOG_Y - 1 * GRID_H;
          w = DIALOG_W * GRID_W;
          h = 15 * GRID_H;
        };
    
        class TabButtons : A3A_ControlsGroupNoScrollbars
        {
            idc = A3A_IDC_MAINDIALOGTABBUTTONS;
            x = DIALOG_X;
            y = DIALOG_Y - 5 * GRID_H;
            w = DIALOG_W * GRID_W;
            h = 10 * GRID_H;

            class Controls
            {
                class VehicleTabButton : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_all;
                    onButtonClick = "[""switchTab"", [""all""]] call A3A_fnc_blackMarketDialog";
                    x = 125 * GRID_W;
                    y = 10 * GRID_H;
                    w = 35 * GRID_W;
                    h = 5 * GRID_H;
                };

                class VehicleTabButton1 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_arty;
                    onButtonClick = "[""switchTab"", [""artyllery""]] call A3A_fnc_blackMarketDialog";
                    x = 0 * GRID_W;
                    y = 0;
                    w = 35 * GRID_W;
                    h = 5 * GRID_H;
                };

                class VehicleTabButton2 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_apc;
                    onButtonClick = "[""switchTab"", [""apc""]] call A3A_fnc_blackMarketDialog";
                    x = 35 * GRID_W;
                    y = 0;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };
            
                class VehicleTabButton3 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_AA;
                    onButtonClick = "[""switchTab"", [""AA""]] call A3A_fnc_blackMarketDialog";
                    x = 65 * GRID_W;
                    y = 0;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };

                class VehicleTabButton4 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_uav;
                    onButtonClick = "[""switchTab"", [""uav""]] call A3A_fnc_blackMarketDialog";
                    x = 95 * GRID_W;
                    y = 0;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };
                class VehicleTabButton5 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_tank;
                    onButtonClick = "[""switchTab"", [""tank""]] call A3A_fnc_blackMarketDialog";
                    x = 125 * GRID_W;
                    y = 0;
                    w = 35 * GRID_W;
                    h = 5 * GRID_H;
                };
                class VehicleTabButton6 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_statics;
                    onButtonClick = "[""switchTab"", [""statics""]] call A3A_fnc_blackMarketDialog";
                    x = 0 * GRID_W;
                    y = 5 * GRID_H;
                    w = 35 * GRID_W;
                    h = 5 * GRID_H;
                };
                class VehicleTabButton7 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_heli;
                    onButtonClick = "[""switchTab"", [""heli""]] call A3A_fnc_blackMarketDialog";
                    x = 35 * GRID_W;
                    y = 5 * GRID_H;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };
                class VehicleTabButton8 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_plane;
                    onButtonClick = "[""switchTab"", [""plane""]] call A3A_fnc_blackMarketDialog";
                    x = 65 * GRID_W;
                    y = 5 * GRID_H;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };

                class VehicleTabButton9 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_armedcar;
                    onButtonClick = "[""switchTab"", [""armedcar""]] call A3A_fnc_blackMarketDialog";
                    x = 95 * GRID_W;
                    y = 5 * GRID_H;
                    w = 30 * GRID_W;
                    h = 5 * GRID_H;
                };

                class VehicleTabButton10 : A3A_Button
                {
                    idc = -1;
                    text = $STR_antistasi_dialogs_vehicle_tab_unarmedcar;
                    onButtonClick = "[""switchTab"", [""unarmedcar""]] call A3A_fnc_blackMarketDialog";
                    x = 125 * GRID_W;
                    y = 5 * GRID_H;
                    w = 35 * GRID_W;
                    h = 5 * GRID_H;
                };
            };

        };

        // Main content
        class VehicleTab : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETMAIN;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUP;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabArty : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETARTY;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPATRY;
                    x = 0;
                    y = 4 * GRID_H; //9.5
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H; //9.5
                };
            };
        };
        class VehicleTabApc : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETAPC;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPAPC;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabAA : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETAA;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPAA;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabUav : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETUAV;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPUAV;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabTank : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETTANK;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPTANK;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabStatics : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETSTATICS;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPSTATICS;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabHeli : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETHELI;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPHELI;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabPlane : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETPLANE;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPPLANE;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabArmedCar : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETARMEDCAR;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPARMEDCAR;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };
        class VehicleTabUnarmedCar : A3A_DefaultControlsGroup
        {
            idc = A3A_IDC_BLACKMARKETUNARMEDCAR;
            show = false;

            class Controls
            {
                class VehiclesControlsGroup : A3A_ControlsGroupNoHScrollbars
                {
                    idc = A3A_IDC_BLACKMARKETVEHICLESGROUPUNARMED;
                    x = 0;
                    y = 4 * GRID_H;
                    w = PX_W(DIALOG_W);
                    h = PX_H(DIALOG_H) - 8 * GRID_H;
                };
            };
        };

        class CloseButton : A3A_CloseButton
        {
            idc = -1;
            x = DIALOG_X + DIALOG_W * GRID_W - 5 * GRID_W;
            y = DIALOG_Y - 10 * GRID_H;
        };
    };

    // Used for preview renders. Has to be defined inline. Class inheritance incompatible. ctrlCreate incompatible.
    class Objects
    {
        class VehiclePreview
        {
            idc = A3A_IDC_BLACKMARKETBUYOBJECTRENDER;

            type = 82;
            model = "\A3\Structures_F\Items\Food\Can_V3_F.p3d";
            scale = 0.00001;  // Hide unless there is a mouse hover. This is overwritten by proper ctrlShow command on initialisation.

            direction[] = {0, -0.35, -0.65};
            up[] = {0, 0.65, -0.35};

            x = 0.5;
            y = 0.5;
            z = 0.2;

            xBack = 0.5;
            yBack = 0.5;
            zBack = 1.2;

            inBack = 1;
            enableZoom = 1;
            zoomDuration = 0.001;
        };
    };
};
