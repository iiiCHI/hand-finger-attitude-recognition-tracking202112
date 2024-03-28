using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
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

        private int Rotate = 197;
        private int RotateRageindex = 0;
        private bool isRotate = false;

        private double Zoom = 1.0;//这个用来表示放大缩小


        /*
         拖拽移动
         */
        private bool isDragging;
        private Point offset;



        #endregion

        public Form1()
        {
            InitializeComponent();

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string FigName = "Figure " + (2+comboBox1.SelectedIndex*2+ comboBox2.SelectedIndex).ToString();

            // 查找窗口
            IntPtr figureWindow = figureWindow_box2[2 + comboBox1.SelectedIndex * 2 + comboBox2.SelectedIndex];

            if (figureWindow != IntPtr.Zero)
            {
                MessageBox.Show(comboBox1.Text + comboBox2.Text + "已经查找到！", "手指状态展示", MessageBoxButtons.OK, MessageBoxIcon.None);
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
            for (int i = 2; i <= 8; i++)
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
                MessageBox.Show("未找到相关窗口，请检查连接");
            }

        }

        private void button3_Click(object sender, EventArgs e)
        {
            // 查找窗口
            IntPtr figureWindow = figureWindow_box2[8];

            if (figureWindow != IntPtr.Zero)
            {
                MessageBox.Show("震颤视图已经查找到！", "震颤状态展示", MessageBoxButtons.OK, MessageBoxIcon.None);
                // 修改Figure 1窗口的样式，使其无边框
                int style = GetWindowLong(figureWindow, GWL_STYLE);
                style = style & ~WS_POPUP;
                style = style | WS_CHILD | WS_VISIBLE;
                style = style & ~WS_BORDER & ~WS_CAPTION; // 无边框
                SetWindowLong(figureWindow, GWL_STYLE, (IntPtr)style);

                // 将Figure 1窗口嵌入到pictureBox1中
                SetParent(figureWindow, pictureBox3.Handle);

                // 调整Figure 1窗口的位置和大小，确保适应pictureBox1的尺寸
                MoveWindow(figureWindow, 0, 0, pictureBox3.Width + 5, pictureBox3.Height + 5, true);
                //SetWindowPos(figureWindow, IntPtr.Zero, 0, 0, pictureBox1.Width, pictureBox1.Height, SWP_NOSIZE | SWP_NOZORDER);
            }
            else
            {
                MessageBox.Show("未找到 震颤 窗口");
            }
        }
        // 在你的代码中旋转图像的方法
        // 旋转图像的方法
        private Image RotateImage(Image img, float angle)
        {
            // 创建一个新的位图，以保存旋转后的图像
            Bitmap rotatedImage = new Bitmap(img.Width*2, img.Height*2);

            // 使用Graphics对象绘制旋转后的图像
            using (Graphics g = Graphics.FromImage(rotatedImage))
            {
                // 设置图像的插值模式为高质量
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.SmoothingMode = SmoothingMode.HighQuality;

                // 创建一个矩阵对象并进行旋转变换
                Matrix matrix = new Matrix();
                matrix.Translate((float)img.Width / 2, (float)img.Height / 2);
                matrix.Rotate(angle);
                matrix.Translate(-(float)img.Width / 2, -(float)img.Height / 2);

                // 应用变换矩阵并绘制图像
                g.Transform = matrix;
                g.DrawImage(img, new Rectangle(0, 0, img.Width, img.Height));

            }

            return rotatedImage;
        }

        private void pictureBox4_MouseDown(object sender, MouseEventArgs e)
        {
            isDragging = true;
            // 计算鼠标相对于PictureBox左上角的偏移量
            offset = new Point(e.X, e.Y);
        }

        private void pictureBox4_MouseUp(object sender, MouseEventArgs e)
        {
            isDragging = false;
        }

        private void pictureBox4_MouseMove(object sender, MouseEventArgs e)
        {
            if (isDragging)
            {
                // 将PictureBox的新位置设置为鼠标当前位置减去偏移量
                pictureBox4.Left = e.X + pictureBox4.Left - offset.X;
                pictureBox4.Top = e.Y + pictureBox4.Top - offset.Y;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            pictureBox4.SizeMode = PictureBoxSizeMode.CenterImage; // 设置 PictureBox 的 SizeMode 为 CenterImage
            pictureBox5.SizeMode = PictureBoxSizeMode.CenterImage; // 设置 PictureBox 的 SizeMode 为 CenterImage
            pictureBox4.Image = Image.FromFile("../../../rotated_images/rotated_image_197.png");

        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.R)//R表示开始旋转
            {
                Console.WriteLine("R key pressed");
                RotateRageindex = Control.MousePosition.X;
                isRotate = true;
            }
            if (e.KeyCode == Keys.Z)//Z表示放大
            {
                Zoom += 0.05;
                if (Zoom > 8)
                {
                    Zoom = 8;
                }
                pictureBox5.Image = Image.FromFile("../../../zoom_images/zoom_缩小倍率" + string.Format("{0:0.00}", Zoom) + ".png");
                //zoom_缩小倍率8.00.png
            }
            if (e.KeyCode == Keys.X)//Z表示放大
            {
                Zoom -= 0.05;
                if (Zoom < 0.01)
                {
                    Zoom = 0.01;
                }
                pictureBox5.Image = Image.FromFile("../../../zoom_images/zoom_缩小倍率" + string.Format("{0:0.00}", Zoom) + ".png");
                //zoom_缩小倍率8.00.png
            }
        }

        private void Form1_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.R)//R表示开始旋转
            {
                Console.WriteLine("R key pressed");
                RotateRageindex = Control.MousePosition.X;
                isRotate = false;
            }
        }

        private void tabPage4_MouseMove(object sender, MouseEventArgs e)
        {
            if (isRotate)
            {
                Rotate += 3600;
                int Rotatelength = Control.MousePosition.X - RotateRageindex;
                Rotate = (Rotate + Rotatelength) % 360;
                pictureBox4.Image = Image.FromFile("../../../rotated_images/rotated_image_"+ Rotate.ToString()+ ".png");
            }
        }
    }
}
