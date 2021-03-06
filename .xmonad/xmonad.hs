import qualified Data.Map as M
import Data.Monoid
import System.Exit

import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.MouseResize
import XMonad.Actions.WindowNavigation

-- Hooks
import XMonad.Hooks.DynamicBars
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)

-- layouts
import XMonad.Layout.Magnifier
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing

-- layout modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.MultiToggle as Mt
  ( EOT(EOT)
  , Toggle(Toggle)
  , (??)
  , mkToggle
  )
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowArranger
import XMonad.Layout.WindowNavigation

myFont = "xft:FiraCode Nerd Font:pixelsize=11:antialias=true:hinting=true"

-- drac colors
background = "#282a36"

selection = "#44475a"

foreground = "#f8f8f2"

comment = "#6272a4"

cyan = "#8be9fd"

green = "#50fa7b"

orange = "#ffb86c"

pink = "#ff79c6"

purple = "#bd93f9"

red = "#ff5555"

yellow = "#f1fa8c"

-- The preferred terminal program, which is used in a binding below and by
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = background

myFocusedBorderColor = cyan

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    -- launch a terminal
  [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
  , ((modm, xK_p), spawn "dmenu_run")
    -- launch rofi
  , ((modm, xK_d), spawn "rofi -show drun")
    -- close focused window
  , ((modm .|. shiftMask, xK_q), kill)
     -- Rotate through the available layout algorithms
  , ((modm, xK_space), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
  , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    -- , ((modm,               xK_n     ), refresh)
    -- Move focus to the next window
  , ((modm, xK_j), windows W.focusDown)
    -- Move focus to the previous window
  , ((modm, xK_k), windows W.focusUp)
    -- Move focus to the master window
  , ((modm, xK_m), windows W.focusMaster)
    -- Swap the focused window and the master window
  , ((modm, xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
  , ((modm .|. shiftMask, xK_j), windows W.swapDown)
    -- Swap the focused window with the previous window
  , ((modm .|. shiftMask, xK_k), windows W.swapUp)
    -- Shrink the master area
  , ((modm, xK_h), sendMessage Shrink)
    -- Expand the master area
  , ((modm, xK_l), sendMessage Expand)
    -- Push window back into tiling
  , ((modm, xK_t), withFocused $ windows . W.sink)
    -- , ((modm,               xK_y     ), withFocused $ windows . W.float)
  , ((modm, xK_Right), sendMessage $ Go R)
  , ((modm, xK_Left), sendMessage $ Go L)
  , ((modm, xK_Up), sendMessage $ Go U)
  , ((modm, xK_Down), sendMessage $ Go D)
  , ((modm .|. shiftMask, xK_Right), sendMessage $ Swap R)
  , ((modm .|. shiftMask, xK_Left), sendMessage $ Swap L)
  , ((modm .|. shiftMask, xK_Up), sendMessage $ Swap U)
  , ((modm .|. shiftMask, xK_Down), sendMessage $ Swap D)
    -- switch to next monitor
  , ((modm, xK_Tab), nextScreen)
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
  , ((modm, xK_b), sendMessage ToggleStruts)
  , ((modm, xK_f), sendMessage $ Mt.Toggle NBFULL)
    -- Restart xmonad
  , ( (modm .|. shiftMask, xK_r)
    , spawn
        "xmonad --recompile && xmonad --restart && notify-send 'XMonad Restarted'")
    -- quit menu
  , ((modm, xK_0), spawn "$HOME/.local/bin/powermenu")
  ] ++
  --
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  --
  [ ((m .|. modm, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ] ++
  --
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2
  -- mod-shift-{w,e,r}, Move client to screen 1, 2
  --
  [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
  | (key, sc) <- zip [xK_w, xK_e] [0 ..]
  , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
  ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings XConfig {XMonad.modMask = modm} =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1)
      , \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ( (modm, button3)
      , \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
myTabTheme =
  def
    { fontName = myFont
    , inactiveTextColor = comment
    , inactiveColor = background
    , inactiveBorderColor = background
    , activeTextColor = foreground
    , activeColor = cyan
    , activeBorderColor = cyan
    }

--Makes setting the spacingRaw simpler to write.
--The spacingRaw module adds a configurable amount of space around windows.
mySpacing ::
     Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

magnify =
  renamed [Replace "Magnify"] $
  windowNavigation $
  addTabs shrinkText myTabTheme $
  subLayout [] (smartBorders Simplest) $
  magnifier $
  limitWindows 12 $ mySpacing 8 $ ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "Monocle"] $
  windowNavigation $
  addTabs shrinkText myTabTheme $
  subLayout [] (smartBorders Simplest) $ limitWindows 20 Full

vert = renamed [Replace "Vert"] $ windowNavigation $ Tall 1 (3 / 100) (1 / 2)

horiz = renamed [Replace "Horiz"] $ Mirror vert

myLayout =
  avoidStruts $
  mouseResize $ windowArrange $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) layouts
  where
    layouts = magnify ||| vert ||| monocle ||| horiz

------------------------------------------------------------------------
-- Window rules:
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =
  composeAll
    [ className =? "MPlayer" --> doFloat
    , className =? "Gimp" --> doFloat
    , resource =? "desktop_window" --> doIgnore
    , resource =? "kdesktop" --> doIgnore
    ]

------------------------------------------------------------------------
-- Event handling
-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = fadeWindowsEventHook

------------------------------------------------------------------------
-- Status bars and logging
myLogHook :: X ()
myLogHook = fadeWindowsLogHook myFadeHook
  where
    myFadeHook = composeAll [isUnfocused --> transparency 0.5, opaque]

------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "nitrogen --restore &"
  spawnOnce "picom -b &"
  spawnOnce "flameshot &"
  spawn
    "killall trayer; \
    \trayer --edge top \
    \--align right \
    \--widthtype request \
    \--padding 6 \
    \--SetDockType true \
    \--SetPartialStrut true \
    \--expand true \
    \--monitor 0 \
    \--transparent true \
    \--alpha 0 \
    \--tint 0x282c34 \
    \--height 18 &"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
  xmproc0 <- spawnPipe "xmobar  $HOME/.config/xmobar/xmobarrc0.hs"
  xmonad $
    docks $
    ewmh
      def
        { terminal = myTerminal
        , focusFollowsMouse = myFocusFollowsMouse
        , clickJustFocuses = myClickJustFocuses
        , borderWidth = myBorderWidth
        , modMask = myModMask
        , workspaces = myWorkspaces
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        -- bindings
        , keys = myKeys
        , mouseBindings = myMouseBindings
        -- hooks, layouts
        , layoutHook = myLayout
        , manageHook = myManageHook
        , handleEventHook = myEventHook
        , startupHook = myStartupHook
        , logHook =
            workspaceHistoryHook <+>
            myLogHook <+>
            dynamicLogWithPP
              xmobarPP
                -- outputs of the entire bar
                -- input from xmonad gets sent to xmonad proc 0,
                -- then the output from that gets sent into hPutStrLn
                -- and then into xmonad to be displayed
                { ppOutput = hPutStrLn xmproc0
                , ppCurrent = xmobarColor cyan "" . wrap "[" "]"
                , ppVisible = xmobarColor comment "" . wrap "(" ")"
                , ppTitle = xmobarColor purple "" . pad . shorten 20
                , ppLayout = xmobarColor red "" . wrap "<" ">"
                , ppSep = " "
                , ppOrder = \(ws:l:t:_) -> [ws, t, l]
                }
        }