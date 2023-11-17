using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Media;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows.Forms;
namespace Tremors
{
    public partial class Form1 : Form
    {
        private TcpListener tcpListener;
        private Thread listenerThread;

        //属性
        public int UserId;      //用户ID
        public int Times;       //执行次数
        public int Round;       //Target的大小

        public int Area;       //表示所在区域，1为非交互区，2为交互区，3目标区。

        long Rst_start;//休息起始时间
        long Rst_end;//休息终止时间

        long Act_start;//交互起始时间
        long Act_end;//交互终止时间

        long Tar_start;//目标起始时间
        long Tar_end;//目标终止时间

        int IsDone; //用于判断当前要去往的工作区，1表示rst，2表示start，3表示taiget，4表示done

        //文件地址
        public string FilePath_rowIMU;
        public string FilePath_UserAction;

        //设置时间戳，多少秒移动一次
        int flag_number;


        public Form1()
        {
            InitializeComponent();
            //Directory.CreateDirectory(FilePath);

            //设置中央启动
            CenterFormOnSecondMonitor();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //初始化变量
            Show("请输入UserId:", "输入", out UserId);
            //初始化文件地址
            FilePath_rowIMU = "../../../../dataSet/UserId_" + UserId.ToString() + "_RowImu.csv";
            FilePath_UserAction = "../../../../dataSet/UserId_" + UserId.ToString() + "_UserAction.csv";

            //Cursor.Hide();
            StartServer();
            //
            Cursor = Cursors.Hand;

            //初始化
            InitFile();
            

        }



        private void InitFile()
        {
            using (StreamWriter sw = new StreamWriter(FilePath_UserAction, true)) // 使用true参数以追加模式打开文件
            {
                sw.WriteLine("Round, Times, Rst_start, Rst_end, Act_start, Act_end, Tar_start, Tar_end, timestamp");
            }
            using (StreamWriter sw = new StreamWriter(FilePath_rowIMU, true)) // 使用true参数以追加模式打开文件
            {
                sw.WriteLine("Acc1_x,Acc1_y,Acc1_z,Gyro1_x,Gyro1_y,Gyro1_z,Acc2_x,Acc2_y,Acc2_z,Gyro2_x,Gyro2_y,Gyro2_z,Sampling rate,Timestamp");
            }


            //初始化光标
            hand_point.Paint += Hand_point_Paint;
            Round = 180;
            //初始化term区域
            InitTimes(0);
        }

        private void InitTimes(int tem)
        {
            IsDone = 1;//新一轮开始
            //设置时间函数，记录时间，记录七秒钟数据
            Area = 1;//当前在非交互区

            //重置时间戳
            Rst_start = 0;//休息起始时间
            Rst_end = 0;//休息终止时间

            Act_start = 0;//交互起始时间
            Act_end = 0;//交互终止时间

            Tar_start = 0;//目标起始时间
            Tar_end = 0;//目标终止时间

            Times = tem;//标定轮数

            label1.Text = "第" + Times.ToString() + "轮";

            int x = 532;
            int y = 898;
            hand_point.Location = new Point(x, y);
            Cursor.Position = new Point(x, y);

            //进度条消失
            progressBar1.Visible = false;

            //改变目标区的大小和label的位置
            panel_target.Size = new Size(Round, 523);
            //修改label的位置，保证在正中心
            label_target1.Location = new Point((Round - 114)/2,55);
            label_target2.Location = new Point((Round - 114) / 2, 185);
            label_target3.Location = new Point((Round - 114) / 2, 321);
            panel_target.Location = new Point(1786  - Round / 2, 1);
                        
            if (Times == 0)
            {
                return;
            }

            HighLightItem("None采集");

            //直接保存七秒的数据
            Thread SaveDataThread = new Thread(SaveData);
            SaveDataThread.Start();
        }

        private void SaveData()
        {
            //long Rst_start;//休息起始时间
            //long Rst_end;//休息终止时间

            //long Act_start;//交互起始时间
            //long Act_end;//交互终止时间

            //long Tar_start;//目标起始时间
            //long Tar_end;//目标终止时间
            switch (Area)//表示所在区域，1为非交互区，2为交互区，3目标区。
            {
                case 1:
                    Rst_start = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                    break;
                case 2:
                    break;
                default:
                    Tar_start = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                    this.Invoke((MethodInvoker)delegate
                    {
                        panel_target.BackColor = Color.Green;
                    });
                        break;
            }
            //Thread.Sleep(7000);//保存七秒的数据
            this.Invoke((MethodInvoker)delegate
            {
                progressBar2.Visible = true;
            });
            // 设置进度条的最大值为100
            //progressBar2.Maximum = 700;
                // 循环更新进度条，每隔100毫秒更新一次，总共更新70次，模拟七秒钟的时间
            for (int i = 1; i <= 70; i++)
            {
                // 在UI线程上更新进度条的值
                this.Invoke((MethodInvoker)delegate
                {
                    progressBar2.Value = i*10;
                });

                // 等待100毫秒
                Thread.Sleep(100);
            }
            this.Invoke((MethodInvoker)delegate
            {
                progressBar2.Visible = false;
            });


            SystemSounds.Beep.Play();

            switch (Area)//表示所在区域，1为非交互区，2为交互区，3目标区。
            {
                case 1:
                    Rst_end = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                    //保存完播放声音，下一个状态
                    HighLightItem("起始");
                    //进入下一个阶段
                    IsDone = 2;
                    break;
                case 2:
                    break;
                default:

                    this.Invoke((MethodInvoker)delegate
                    {
                        panel_target.BackColor = Color.FromArgb(128, 255, 128);
                    });
                    Tar_end = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                    this.Invoke((MethodInvoker)delegate
                    {
                        label1.Text = label1.Text + " 完成!";
                    });
                    //MessageBox.Show("本轮完成！");
                    break;
            }



        }

        public static DialogResult Show(string prompt, string title, out int result)
        {
            Form promptForm = new Form()
            {
                Width = 300,
                Height = 150,
                FormBorderStyle = FormBorderStyle.FixedDialog,
                Text = title,
                StartPosition = FormStartPosition.CenterScreen
            };

            Label promptLabel = new Label()
            {
                Left = 20,
                Top = 20,
                Width = 260,
                Text = prompt
            };

            TextBox inputBox = new TextBox()
            {
                Left = 20,
                Top = 50,
                Width = 260
            };

            Button confirmButton = new Button()
            {
                Text = "确定",
                Left = 180,
                Width = 80,
                Top = 80,
                DialogResult = DialogResult.OK
            };

            confirmButton.Click += (sender, e) => { promptForm.Close(); };
            //confirmButton.IsDefault = true;

            promptForm.Controls.Add(promptLabel);
            promptForm.Controls.Add(inputBox);
            promptForm.Controls.Add(confirmButton);

            //默认button
            promptForm.AcceptButton = confirmButton;


            DialogResult dialogResult = promptForm.ShowDialog();
            result = 0;

            if (dialogResult == DialogResult.OK)
            {
                if (int.TryParse(inputBox.Text, out result))
                {
                    return DialogResult.OK;
                }
                else
                {
                    MessageBox.Show("请输入有效的整数！", "错误", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return Show(prompt, title, out result);
                }
            }
            else
            {
                return DialogResult.Cancel;
            }
        }




        private void StartServer()
        {
            tcpListener = new TcpListener(IPAddress.Any, 8080);
            listenerThread = new Thread(new ThreadStart(ListenForClients));
            listenerThread.Start();

        }

        private void ListenForClients()
        {
            this.tcpListener.Start();

            while (true)
            {
                // blocks until a client has connected to the server
                TcpClient client = this.tcpListener.AcceptTcpClient();

                // create a thread to handle communication with the connected client
                Thread clientThread = new Thread(new ParameterizedThreadStart(HandleClientComm));
                clientThread.Start(client);
            }
        }

        private void HandleClientComm(object clientObj)
        {
            TcpClient tcpClient = (TcpClient)clientObj;
            NetworkStream clientStream = tcpClient.GetStream();

            StreamReader reader = new StreamReader(clientStream, Encoding.ASCII);

            while (true)
            {
                try
                {
                    // Read a line of data (assuming each line has 13 items separated by spaces)
                    string data = reader.ReadLine();

                    if (data != null)
                    {
                        // Process the data as needed
                        ProcessData(data);
                    }
                    else
                    {
                        // Connection closed by the client
                        MessageBox.Show("Error");
                        break;
                    }
                }
                catch (IOException)
                {
                    // Handle IOException (e.g., client disconnected)
                    break;
                }
            }

            tcpClient.Close();
        }

        private void ProcessData(string data)
        {
            // Split the data into 13 items using spaces
            string[] items = data.Split(' ');
            //
            // 将字符串数组转换为浮点数数组
            float[] floatValues;
            try
            {
                floatValues = Array.ConvertAll(items.Where(s => !string.IsNullOrEmpty(s)).ToArray(), float.Parse);
            }
            catch (Exception)
            {
                return;
            }
            if (floatValues.Length != 13)
            {
                return;
            }
            long timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();//这个保存int到纳秒的时间戳。
            using (StreamWriter sw = new StreamWriter(FilePath_rowIMU, true)) // 使用true参数以追加模式打开文件
            {
                sw.WriteLine(string.Join(",", floatValues) + ','+ timestamp.ToString());
                //label1.Text = string.Format("{0},{1},{2},{3},{4}", UserId, Times, Round, 1, timestamp);
            }

            //显示出来

            flag_number++;
            if (flag_number == 3)
            {
                flag_number = 0;
            }
            else
            {
                return;
            }
            // Update UI or perform any other required processing
            this.Invoke((MethodInvoker)delegate
            {
                // Update UI or perform any UI-related actions
                // 在创建 label1 的线程上执行更新操作
                //this.label1.Text = string.Join(",", floatValues);

                //// 获取 PictureBox 的位置
                //Point currentLocation = hand_point.Location;
                //int x = currentLocation.X - (int)(floatValues[11] / 3);
                //int y = currentLocation.Y + (int)(floatValues[9] / 5);
                ////分别对应10、11、12
                //if (x == currentLocation.X&&y == currentLocation.Y)
                //{
                //    return;
                //}
                //// 设置 PictureBox 的位置
                //hand_point.Location = new Point(x < 0 ? 0:x, y<0?0:y);

                // 获取 PictureBox 的位置
                Point currentLocation = hand_point.Location;
                int x = currentLocation.X - (int)(floatValues[11] / 3);
                int y = currentLocation.Y + (int)(floatValues[9] / 5);

                //分别对应10、11、12
                if (x == currentLocation.X && y == currentLocation.Y)
                {
                    return;
                }
                x = x < 2 ? 2 : x;
                x = x > 1920 ? 1920 : x;
                y = y < 2 ? 2 : y;
                y = y > 1080 ? 1080 : y;
                // 设置 PictureBox 的位置
                hand_point.Location = new Point(x, y);
                Cursor.Position = new Point(x, y);

            });
        }




        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            long timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();//这个保存int到纳秒的时间戳。
            if (Times > 0)
            {
                using (StreamWriter sw = new StreamWriter(FilePath_UserAction, true)) // 使用true参数以追加模式打开文件
                {
                    sw.WriteLine("{0},{1},{2},{3},{4},{5},{6},{7},{8}", Round, Times, Rst_start, Rst_end, Act_start, Act_end, Tar_start, Tar_end, timestamp);
                }
            }

            if (e.KeyCode == Keys.D1 || e.KeyCode == Keys.NumPad1)
            {
                Times = -1;
                Round = 30;
                MessageBox.Show("当前任务A，切换成功！");
            }
            if (e.KeyCode == Keys.D2 || e.KeyCode == Keys.NumPad2)
            {
                Times = -1;
                Round = 90;
                MessageBox.Show("当前任务B，切换成功！");
            }
            if (e.KeyCode == Keys.D3 || e.KeyCode == Keys.NumPad3)
            {
                Times = -1;
                Round = 180;
                MessageBox.Show("当前任务C，切换成功！");
            }

            if (e.KeyCode == Keys.N)
            {
                //N表示Next，下一轮Times
                InitTimes(Times + 1);
            }
        }
        private void panel1_Paint(object sender, PaintEventArgs e)
        {
            //throw new NotImplementedException();
        }


        private void HighLightItem(string ItemName)//ItemName = "交互"，"起始"，"目标","Target保持"
        {
            //图片的背景色
            //panel_rst.BackColor = SystemColors.Control;
            //panel_target.BackColor = SystemColors.Control;
            //panel_act.BackColor = SystemColors.Control;
            //lable的背景色
            label_none.ForeColor = SystemColors.ControlDark;

            label_rst1.ForeColor = SystemColors.ControlDark;
            label_rst2.ForeColor = SystemColors.ControlDark;
            label_rst3.ForeColor = SystemColors.ControlDark;

            label_target1.ForeColor = SystemColors.ControlDark;
            label_target2.ForeColor = SystemColors.ControlDark;
            label_target3.ForeColor = SystemColors.ControlDark;

            label_act.ForeColor = SystemColors.ControlDark;

            //label1.Text = "init";
            BackColor = SystemColors.GradientInactiveCaption;

            switch (ItemName)
            {
                case "None采集":
                    BackColor = SystemColors.GradientActiveCaption;
                    label_none.ForeColor = SystemColors.ControlText;
                    break;
                case "交互":
                    label_none.ForeColor = SystemColors.ControlText;
                    break;
                case "起始":
                    label_rst1.ForeColor = SystemColors.ControlText;
                    label_rst2.ForeColor = SystemColors.ControlText;
                    label_rst3.ForeColor = SystemColors.ControlText;
                    break;

                case "目标":
                    label_target1.ForeColor = SystemColors.ControlText;
                    label_target2.ForeColor = SystemColors.ControlText;
                    label_target3.ForeColor = SystemColors.ControlText;

                    label_act.ForeColor = SystemColors.ControlText;
                    break;

                case "Tar":
                    label_target1.ForeColor = SystemColors.ControlText;
                    label_target2.ForeColor = SystemColors.ControlText;
                    label_target3.ForeColor = SystemColors.ControlText;

                    break;

            }
        }

        private void panel_target_MouseHover(object sender, EventArgs e)
        {
            if (progressBar1.Visible == false|| IsDone!=3)
            {
                return;
            }
            IsDone = 4;


            Act_end = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

            Thread SaveDataThread = new Thread(Delay_panel_target_MouseHover);
            SaveDataThread.Start();


            //SaveData();
        }

        private void Delay_panel_target_MouseHover()
        {
            Thread.Sleep(1000);
            //设置IsDone表示结束
            label_act.ForeColor = SystemColors.ControlDark;

            this.Invoke((MethodInvoker)delegate
            {
                progressBar1.Visible = false;
            });
            Area = 3;
            Thread SaveDataThread = new Thread(SaveData);
            SaveDataThread.Start();
        }

        private void panel_rst_MouseHover(object sender, EventArgs e)
        {
            if (progressBar1.Visible == true || IsDone != 2)
            {
                return;
            }
            IsDone = 3;//表示进入下一阶段
            Thread SaveDataThread = new Thread(Delay_panel_rst_MouseHover);
            SaveDataThread.Start();
        }

        private void Delay_panel_rst_MouseHover()
        {
            Thread.Sleep(1000);

            //播放铃声
            SystemSounds.Beep.Play();

            HighLightItem("目标");//意图进入目标区
            Act_start = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

            this.Invoke((MethodInvoker)delegate
            {
                //暂时不要进度条了
                progressBar1.Visible = true;
            });
            // 启动一个新线程来模拟进度条填充过程
            Thread progressBarThread = new Thread(FillProgressBar);
            progressBarThread.Start();
        }


        #region 生成文件


        private void FillProgressBar()
        {
            // 设置进度条的最大值为100
            //progressBar1.Maximum = 700;

            // 循环更新进度条，每隔100毫秒更新一次，总共更新70次，模拟七秒钟的时间
            //for (int i = 0; i <= progressBar1.Maximum; i++)
            //{
            //    // 在UI线程上更新进度条的值
            //    this.Invoke((MethodInvoker)delegate
            //    {
            //        progressBar1.Value = i;
            //    });

            //    // 等待100毫秒
            //    Thread.Sleep(7000 / progressBar2.Maximum);
            //}
        }

        private void CenterFormOnSecondMonitor()
        {
            // 检查是否有多个显示器
            if (Screen.AllScreens.Length > 1)
            {
                // 获取第二个显示器的屏幕
                Screen secondScreen = Screen.AllScreens[1];

                // 设置窗体位置为第二个显示器的中央
                this.StartPosition = FormStartPosition.Manual;
                this.Location = new System.Drawing.Point(
                    secondScreen.Bounds.Left + (secondScreen.Bounds.Width - this.Width) / 2,
                    secondScreen.Bounds.Top + (secondScreen.Bounds.Height - this.Height) / 2
                );
            }
            else
            {
                // 如果只有一个显示器，将窗体居中显示在主屏幕
                this.StartPosition = FormStartPosition.CenterScreen;
            }



            //初始化边框
            this.WindowState = FormWindowState.Maximized;
            this.FormBorderStyle = FormBorderStyle.None; // 设置为无边框
        }

        private void Hand_point_Paint(object sender, PaintEventArgs e)
        {
            // 获取PictureBox的Graphics对象
            Graphics g = e.Graphics;

            // 创建一个圆形区域
            GraphicsPath path = new GraphicsPath();
            path.AddEllipse(0, 0, hand_point.Width, hand_point.Height);

            // 将PictureBox的区域设置为圆形区域
            Region region = new Region(path);
            hand_point.Region = region;

            // 释放资源
            path.Dispose();
            region.Dispose();

        }
        private void panel_target_MouseEnter(object sender, EventArgs e)
        {

            //进入之后就终止
        }
        #endregion


    }
}
//
//////lable设置为不可用，明天来搞。