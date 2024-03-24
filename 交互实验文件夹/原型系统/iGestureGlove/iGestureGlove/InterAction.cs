using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Runtime.InteropServices; // 对Windows窗体进行的操作
using System.Windows.Forms; // 对C#窗体进行的操作

namespace iGestureGlove
{
    public partial class InterAction : Form
    {

        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, IntPtr dwNewLong);
        [DllImport("user32.dll", SetLastError = true)]
        internal static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        const int GWL_STYLE = -16;
        const int WS_CHILD = 0x40000000;
        const int WS_VISIBLE = 0x10000000;
        const int WS_POPUP = unchecked((int)0x80000000);
        const int WS_BORDER = 0x00800000;
        const int WS_CAPTION = 0x00C00000;

        public InterAction()
        {
            InitializeComponent();

        }

        private void InterAction_Load(object sender, EventArgs e)
        {
            // 查找窗口
            IntPtr figureWindow = FindWindow(null, "Figure 1");

            if (figureWindow != IntPtr.Zero)
            {
                // 修改Figure 1窗口的样式，使其无边框
                int style = GetWindowLong(figureWindow, GWL_STYLE);
                style = style & ~WS_POPUP;
                style = style | WS_CHILD | WS_VISIBLE;
                style = style & ~WS_BORDER & ~WS_CAPTION; // 无边框
                SetWindowLong(figureWindow, GWL_STYLE, (IntPtr)style);

                // 将Figure 1窗口嵌入到pictureBox1中
                SetParent(figureWindow, pictureBox1.Handle);

                // 调整Figure 1窗口的位置和大小，确保适应pictureBox1的尺寸
                MoveWindow(figureWindow, 0, 0, pictureBox1.Width, pictureBox1.Height, true);
                //SetWindowPos(figureWindow, IntPtr.Zero, 0, 0, pictureBox1.Width, pictureBox1.Height, SWP_NOSIZE | SWP_NOZORDER);
            }
            else
            {
                MessageBox.Show("未找到 Figure 1 窗口");
            }
        }
    }
}
