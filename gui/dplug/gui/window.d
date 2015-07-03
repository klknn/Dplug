/**
* Copyright: Copyright Auburn Sounds 2015 and later.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
* Authors:   Guillaume Piolat
*/
module dplug.gui.window;

import gfm.math;

import ae.utils.graphics;

import dplug.gui.types;

// Giving commands to a window
interface IWindow
{
    // To put in your message loop
    void waitEventAndDispatch();

    // If exit was requested
    bool terminated();

    // Requests exit
    void terminate();

    // Debug-purpose: display debug string
    void debugOutput(string s);

    // Profile-purpose: get time in milliseconds.
    uint getTimeMs();
}

// Receiving commands from a window
interface IWindowListener
{
    /// Called on mouse click.
    /// Returns: true if the event was handled.
    bool onMouseClick(int x, int y, MouseButton mb, bool isDoubleClick, MouseState mstate);

    /// Called on mouse button release
    /// Returns: true if the event was handled.
    bool onMouseRelease(int x, int y, MouseButton mb, MouseState mstate);

    /// Called on mouse wheel movement
    /// Returns: true if the event was handled.
    bool onMouseWheel(int x, int y, int wheelDeltaX, int wheelDeltaY, MouseState mstate);

    /// Called on mouse movement (might not be within the window)
    void onMouseMove(int x, int y, int dx, int dy, MouseState mstate);

    /// Called on keyboard press.
    /// Returns: true if the event was handled.
    bool onKeyDown(Key key);

    /// Called on keyboard release.
    /// Returns: true if the event was handled.
    bool onKeyUp(Key up);

    /// An image you have to draw to, or return that nothing has changed.
    /// The size of this image is given before-hand by onResized.
    /// recomputeDirtyAreas() MUST have been called before.
    /// `swapRB` is true when it is expected rendering will swap red and blue channel.
    void onDraw(ImageRef!RGBA wfb, bool swapRB);

    /// The drawing area size has changed.    
    /// Always called at least once before onDraw.
    void onResized(int width, int height);

    /// Recompute internally what needs be done for the next onDraw.
    /// This function MUST be called before calling `onDraw` and `getDirtyRectangle`.
    /// This method exists to allow the Window to recompute these draw lists less.
    /// And because cache invalidation was easier on user code than internally in the UI.
    void recomputeDirtyAreas();

    /// Returns: Minimal rectangle that contains dirty UIELement in UI + their graphical extent.
    ///          Empty box if nothing to update.
    /// recomputeDirtyAreas() MUST have been called before.
    box2i getDirtyRectangle();

    /// Returns: true if a control must be redrawn.
    bool isUIDirty();

    /// Called whenever mouse capture was canceled (ALT + TAB, SetForegroundWindow...)
    void onMouseCaptureCancelled();

    /// Must be called periodically (ideally 60 times per second but this is not mandatory).
    /// `time` must refer to the window creation time.
    void onAnimate(double dt, double time);
}



// Factory function
IWindow createWindow(void* parentInfo, IWindowListener listener, int width, int height)
{
    version(Windows)
    {
        import win32.windef;
        import dplug.gui.win32window;
        HWND parent = cast(HWND)parentInfo;
        return new Win32Window(parent, listener, width, height);
    }
    else
        return null;
}