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

namespace iGestureGlove
{
    public partial class Form1 : Form
    {
        #region 用于捕捉窗口并展示
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

        IntPtr[] figureWindow_box2 = new IntPtr[10];


        #endregion

        public Form1()
        {
            InitializeComponent();

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string FigName = "Figure " + (2+comboBox1.SelectedIndex*2+ comboBox2.SelectedIndex).ToString();

            MessageBox.Show(FigName+"已经查找到！", "手指状态展示", MessageBoxButtons.OK, MessageBoxIcon.None);
            // 查找窗口
            IntPtr figureWindow = figureWindow_box2[2 + comboBox1.SelectedIndex * 2 + comboBox2.SelectedIndex];

            if (figureWindow != IntPtr.Zero)
            {
                // 修改Figure 1窗口的样式，使其无边框
                int style = GetWindowLong(figureWindow, GWL_STYLE);
                style = style & ~WS_POPUP;
                style = style | WS_CHILD | WS_VISIBLE;
                style = style & ~WS_BORDER & ~WS_CAPTION; // 无边框
                SetWindowLong(figureWindow, GWL_STYLE, (IntPtr)style);

                // 将Figure 1窗口嵌入到pictureBox1中
                SetParent(figureWindow, pictureBox2.Handle);

                // 调整Figure 1窗口的位置和大小，确保适应pictureBox1的尺寸
                MoveWindow(figureWindow, 0, 0, pictureBox2.Width + 5, pictureBox2.Height + 5, true);
                //SetWindowPos(figureWindow, IntPtr.Zero, 0, 0, pictureBox1.Width, pictureBox1.Height, SWP_NOSIZE | SWP_NOZORDER);
            }
            else
            {
                MessageBox.Show("未找到 "+ FigName +" 窗口");
            }
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            MessageBox.Show("数据接入成功！","串口连接",MessageBoxButtons.OK,MessageBoxIcon.None);
            //interAction.Show();

            // 查找窗口
            IntPtr figureWindow = FindWindow(null, "Figure 1");
            for (int i = 2; i <= 7; i++)
            {
                figureWindow_box2[i] = FindWindow(null, "Figure " + i.ToString());
                SetParent(figureWindow_box2[i], pictureBox2.Handle);
            }

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
                MoveWindow(figureWindow, 0, 0, pictureBox1.Width+5, pictureBox1.Height+5, true);
                //SetWindowPos(figureWindow, IntPtr.Zero, 0, 0, pictureBox1.Width, pictureBox1.Height, SWP_NOSIZE | SWP_NOZORDER);
            }
            else
            {
                MessageBox.Show("未找到 Figure 1 窗口");
            }

        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }
    }
}
