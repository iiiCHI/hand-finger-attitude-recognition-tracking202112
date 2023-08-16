using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Threading;
using System.Diagnostics;
using Leap;
using System.IO;
using System.IO.Ports;
using Path = System.IO.Path;

namespace Leap_WPF
{
    struct myPosition
    {
        public double x;
        public double y;
        public double z;
    };

    public partial class MainWindow : Window
    {
        int frameCount = 0;        //帧计数
        int frameInterval = 20;   //帧采样间隔,每隔N帧采集并使用一帧数据进行运算，降低计算资源消耗，采样太密集也没有必要

       
        //手部手指状态存储
        bool[] fingerExtended_Current = new bool[5] { false, false, false, false, false };
        bool[] fingerExtended_Left = new bool[5] { false, false, false, false, false };//左手
        bool[] fingerExtended_Right = new bool[5] { false, false, false, false, false };//右手

        //部分手势的手指状态定义
        bool[] fingerExtended_Rock = new bool[5] { false, false, false, false, false };
        bool[] fingerExtended_Scissor = new bool[5] { false, true, true, false, false };
       
        bool[] fingerExtended_Ok = new bool[5] { false, false, true, true, true };
        bool[] fingerExtended_Tick = new bool[5] { true, true, false, false, false };
        bool[] fingerExtended_Little = new bool[5] { false, false, false, false, true };
        bool[] fingerExtended_Liu = new bool[5] { true, false, false, false, true };


        int sbeject = 0;
        int gesture = 0;
        int sampleNum = 0;

        //定义Leapmotion控制设备
        Leap.Controller controller;

        bool isRecording = false;
        StreamWriter fileWriter1;
        StreamWriter fileWriter2;
        StreamWriter HandFingerJointPositionFileWriter;

        myPosition thumb_p2;
        myPosition index_p2;
        myPosition middle_p2;
        myPosition ring_p2;
        myPosition pinky_p2;
        myPosition palm_p2;

        myPosition thumb_p1;
        myPosition index_p1;
        myPosition middle_p1;
        myPosition ring_p1;
        myPosition pinky_p1;
        myPosition palm_p1;

        myPosition thumb_p0;
        myPosition index_p0;
        myPosition middle_p0;
        myPosition ring_p0;
        myPosition pinky_p0;
        myPosition palm_p0;

        double thumb_v1 = 0;
        double index_v1 = 0;
        double middle_v1 = 0;
        double ring_v1 = 0;
        double pinky_v1 = 0;
        double palm_v1 = 0;

        double thumb_v0 = 0;
        double index_v0 = 0;
        double middle_v0 = 0;
        double ring_v0 = 0;
        double pinky_v0 = 0;
        double palm_v0 = 0;

        int frameIndex = 0;

        static SerialPort serialPort;

        public MainWindow()
        {
            InitializeComponent();

            controller = new Leap.Controller();
            controller.SetPolicy(Leap.Controller.PolicyFlag.POLICY_ALLOW_PAUSE_RESUME);
          

            // 设置监听器
            SampleListener listener = new SampleListener();

            //注册相关事件
            controller.Connect += listener.OnServiceConnect;
            controller.Disconnect += listener.OnServiceDisconnect;
            controller.FrameReady += OnFrame;
            controller.ImageReady += OnImage;
            controller.ImageRequestFailed += OnImageRequestFailed;
            
            controller.Device += listener.OnConnect;
            controller.DeviceLost += listener.OnDisconnect;
            controller.DeviceFailure += listener.OnDeviceFailure;
            controller.LogMessage += listener.OnLogMessage;

            //initial
            thumb_p0.x = 0; thumb_p0.y = 0; thumb_p0.z = 0;
            index_p0.x = 0; index_p0.y = 0; index_p0.z = 0;
            middle_p0.x = 0; middle_p0.y = 0; middle_p0.z = 0;
            ring_p0.x = 0; ring_p0.y = 0; ring_p0.z = 0;
            pinky_p0.x = 0; pinky_p0.y = 0; pinky_p0.z = 0;
            palm_p0.x = 0; palm_p0.y = 0; palm_p0.z = 0;

            thumb_p1.x = 0; thumb_p1.y = 0; thumb_p1.z = 0;
            index_p1.x = 0; index_p1.y = 0; index_p1.z = 0;
            middle_p1.x = 0; middle_p1.y = 0; middle_p1.z = 0;
            ring_p1.x = 0; ring_p1.y = 0; ring_p1.z = 0;
            pinky_p1.x = 0; pinky_p1.y = 0; pinky_p1.z = 0;
            palm_p1.x = 0; palm_p1.y = 0; palm_p1.z = 0;

            thumb_p2.x = 0; thumb_p2.y = 0; thumb_p2.z = 0;
            index_p2.x = 0; index_p2.y = 0; index_p2.z = 0;
            middle_p2.x = 0; middle_p2.y = 0; middle_p2.z = 0;
            ring_p2.x = 0; ring_p2.y = 0; ring_p2.z = 0;
            pinky_p2.x = 0; pinky_p2.y = 0; pinky_p2.z = 0;
            palm_p2.x = 0; palm_p2.y = 0; palm_p2.z = 0;

            serialPort = new SerialPort("COM21", 512000, Parity.None, 8, StopBits.One);
            // 设置接收缓冲区大小为4096字节
            serialPort.ReadBufferSize = 4096;

            // 设置发送缓冲区大小为2048字节
            serialPort.WriteBufferSize = 2048;

        }
        private void music_Ended(object sender, RoutedEventArgs e)
        {
            (sender as MediaElement).Stop();
            (sender as MediaElement).Play();
        }

        //图像格式转换 
        public BitmapSource Convert(System.Drawing.Bitmap bitmap)
        {
            var bitmapData = bitmap.LockBits(
                //new System.Drawing.Rectangle(0, 0, bitmap.Width, bitmap.Height),
                new System.Drawing.Rectangle(0, 0, bitmap.Width, bitmap.Height),
                System.Drawing.Imaging.ImageLockMode.ReadOnly, bitmap.PixelFormat);

            var bitmapSource = BitmapSource.Create(
                bitmapData.Width, bitmapData.Height, 96, 96, PixelFormats.Gray8, null,
                bitmapData.Scan0, bitmapData.Stride * bitmapData.Height, bitmapData.Stride);

            bitmap.UnlockBits(bitmapData);
            return bitmapSource;
        }

        //图像获取显示
        public void OnImage(object sender, ImageEventArgs args)
        {
            if (args.image.IsComplete)
            {
                Leap.Image image = args.image;

                //Bitmap bitmap = new Bitmap(image.Width, image.Height, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
                ////Bitmap bitmap = new Bitmap(640, 440, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
                //ColorPalette grayscale = bitmap.Palette;
                //for (int i = 0; i < 256; i++)
                //{
                //    grayscale.Entries[i] = System.Drawing.Color.FromArgb((int)255, i, i, i);
                //}
                //bitmap.Palette = grayscale;
                //System.Drawing.Rectangle lockArea = new System.Drawing.Rectangle(0, 0, bitmap.Width, bitmap.Height);
                //BitmapData bitmapData = bitmap.LockBits(lockArea, ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
                //byte[] rawImageData = image.Data;
                //System.Runtime.InteropServices.Marshal.Copy(rawImageData, 0, bitmapData.Scan0, image.Width * image.Height);
                //bitmap.UnlockBits(bitmapData);

                BitmapSource bitmapSource = BitmapSource.Create(image.Width, image.Height, 96, 96, System.Windows.Media.PixelFormats.Gray8, null, image.Data, image.Width);

                IRimage.Source = bitmapSource;// Convert(bitmap);

            }


        }
        // 去除四元数括号的辅助函数
        static string RemoveQuaternionBrackets(string quaternionStr)
        {
            return quaternionStr.Replace("(", "").Replace(")", "");
        }
        private void OnImageRequestFailed(object sender, ImageRequestFailedEventArgs args)
        {
            Console.WriteLine("request image failed");
        }

        double handRightPosX = 0;

        
        //数据帧处理
        public void OnFrame(object sender, FrameEventArgs args)
        {
            
            // Get the most recent frame and report some basic information
            Leap.Frame frame = args.frame;


            //获取图像
            var image = controller.RequestImages(frame.Id, Leap.Image.ImageType.DEFAULT);

            int handNum = 0;  //手的数目
            bool[] handExist = new bool[2] { false, false };
            //bool[] handExist = new bool[1] { false };
            if (frame.Hands.Count == 0)
            {
                TobxRight.Text = "右手未检测到";
                TobxLeft.Text = "左手未检测到";
            }
            //MessageBox.Show(frame.Hands.ToString());

            #region
            foreach (Hand hand in frame.Hands)
            {
                handNum++;
                if (hand.IsRight)
                {
                    handExist[0] = true;
                    TobxRight.Text = "右手已经检测到";
                    foreach (Finger finger in hand.Fingers)
                    {
                        // 获取手指的名称
                        string fingerName = finger.Type.ToString();

                        // 获取手指的三个关节的姿态
                        string MetacarpalRotation = RemoveQuaternionBrackets(finger.Bone(Bone.BoneType.TYPE_METACARPAL).Rotation.ToString());
                        string ProximalRotation = RemoveQuaternionBrackets(finger.Bone(Bone.BoneType.TYPE_PROXIMAL).Rotation.ToString());
                        string IntermediateRotation = RemoveQuaternionBrackets(finger.Bone(Bone.BoneType.TYPE_INTERMEDIATE).Rotation.ToString());
                        string DistalRotation = RemoveQuaternionBrackets(finger.Bone(Bone.BoneType.TYPE_DISTAL).Rotation.ToString());

                        // 将姿态信息写入文件
                        if (isRecording)
                        {
                            //serialPort.Write($"{fingerName},{FirRotation},{SecRotation},{ThrRotation},");
                            //serialPort.Write($"{FirRotation},{SecRotation},{ThrRotation},");
                            HandFingerJointPositionFileWriter.Write($"{MetacarpalRotation},{ProximalRotation},{IntermediateRotation},{DistalRotation},");
                        }
                    }
                    // 将姿态信息写入文件
                    if (isRecording)
                        HandFingerJointPositionFileWriter.WriteLine("");
                    //Thread.Sleep(20);
                }
                else
                {
                    TobxRight.Text = "右手未检测到";
                }
                if (hand.IsLeft)
                {
                    TobxLeft.Text = "左手已经检测到";
                    handExist[1] = true;

                    palm_p0.x = hand.PalmPosition.x;
                    palm_p0.y = hand.PalmPosition.y;
                    palm_p0.z = hand.PalmPosition.z;
                    palm_v0 = Math.Sqrt(Math.Pow(hand.PalmVelocity.x, 2) + Math.Pow(hand.PalmVelocity.y, 2) + Math.Pow(hand.PalmVelocity.z, 2));

                    // Get fingers
                    foreach (Finger finger in hand.Fingers)
                    {

                        //position and velocity
                        if (finger.Type == Finger.FingerType.TYPE_THUMB)
                        {
                            thumb_p0.x = finger.TipPosition.x;
                            thumb_p0.y = finger.TipPosition.y;
                            thumb_p0.z = finger.TipPosition.z;

                            thumb_v0 = Math.Sqrt(Math.Pow(finger.TipVelocity.x, 2) + Math.Pow(finger.TipVelocity.y, 2) + Math.Pow(finger.TipVelocity.z, 2));
                        }

                        if (finger.Type == Finger.FingerType.TYPE_INDEX)
                        {
                            index_p0.x = finger.TipPosition.x;
                            index_p0.y = finger.TipPosition.y;
                            index_p0.z = finger.TipPosition.z;

                            index_v0 = Math.Sqrt(Math.Pow(finger.TipVelocity.x, 2) + Math.Pow(finger.TipVelocity.y, 2) + Math.Pow(finger.TipVelocity.z, 2));

                            show.Content = index_p0.x + "\t" + index_p0.y + "\t" + index_p0.z + "\t";
                        }

                        if (finger.Type == Finger.FingerType.TYPE_MIDDLE)
                        {
                            middle_p0.x = finger.TipPosition.x;
                            middle_p0.y = finger.TipPosition.y;
                            middle_p0.z = finger.TipPosition.z;

                            middle_v0 = Math.Sqrt(Math.Pow(finger.TipVelocity.x, 2) + Math.Pow(finger.TipVelocity.y, 2) + Math.Pow(finger.TipVelocity.z, 2));
                        }

                        if (finger.Type == Finger.FingerType.TYPE_RING)
                        {
                            ring_p0.x = finger.TipPosition.x;
                            ring_p0.y = finger.TipPosition.y;
                            ring_p0.z = finger.TipPosition.z;

                            ring_v0 = Math.Sqrt(Math.Pow(finger.TipVelocity.x, 2) + Math.Pow(finger.TipVelocity.y, 2) + Math.Pow(finger.TipVelocity.z, 2));
                        }

                        if (finger.Type == Finger.FingerType.TYPE_PINKY)
                        {
                            pinky_p0.x = finger.TipPosition.x;
                            pinky_p0.y = finger.TipPosition.y;
                            pinky_p0.z = finger.TipPosition.z;

                            pinky_v0 = Math.Sqrt(Math.Pow(finger.TipVelocity.x, 2) + Math.Pow(finger.TipVelocity.y, 2) + Math.Pow(finger.TipVelocity.z, 2));
                        }

                    }

                    if (isRecording)
                    {
                        //write to file
                        string info1 = frameCount + "," + thumb_p1.x + "," + thumb_p1.y + "," + thumb_p1.z + "," + thumb_v1
                            + "," + index_p1.x + "," + index_p1.y + "," + index_p1.z + "," + index_v1
                            + "," + middle_p1.x + "," + middle_p1.y + "," + middle_p1.z + "," + middle_v1
                            + "," + ring_p1.x +"," + ring_p1.y + "," + ring_p1.z + "," + ring_v1
                            + "," + pinky_p1.x + "," + pinky_p1.y + "," +pinky_p1.z + "," +pinky_v1
                            + "," + palm_p1.x + "," + palm_p1.y + "," + palm_p1.z + "," + palm_v1
                            + "," + DateTime.Now.ToString() + "\r\n";
                        fileWriter1.Write(info1);

                        Leap.Vector thumb_vec1 = new Leap.Vector((float)(thumb_p2.x - thumb_p1.x), (float)(thumb_p2.y - thumb_p1.y), (float)(thumb_p2.z - thumb_p1.z));
                        Leap.Vector thumb_vec2 = new Leap.Vector((float)(thumb_p0.x - thumb_p1.x), (float)(thumb_p0.y - thumb_p1.y), (float)(thumb_p0.z - thumb_p1.z));
                        double thumb_angle = thumb_vec1.AngleTo(thumb_vec2);
                        int thumb_angleInt = (int)(thumb_angle / 3.1415926 * 180);
                        int thumb_angleInterval = (thumb_angleInt / 30) + 1;

                        Leap.Vector index_vec1 = new Leap.Vector((float)(index_p2.x - index_p1.x), (float)(index_p2.y - index_p1.y), (float)(index_p2.z - index_p1.z));
                        Leap.Vector index_vec2 = new Leap.Vector((float)(index_p0.x - index_p1.x), (float)(index_p0.y - index_p1.y), (float)(index_p0.z - index_p1.z));
                        double index_angle = index_vec1.AngleTo(index_vec2);
                        int index_angleInt = (int)(thumb_angle / 3.1415926 * 180);
                        int index_angleInterval = (thumb_angleInt / 30) + 1;

                        Leap.Vector middle_vec1 = new Leap.Vector((float)(middle_p2.x - middle_p1.x), (float)(middle_p2.y - middle_p1.y), (float)(middle_p2.z - middle_p1.z));
                        Leap.Vector middle_vec2 = new Leap.Vector((float)(middle_p0.x - middle_p1.x), (float)(middle_p0.y - middle_p1.y), (float)(middle_p0.z - middle_p1.z));
                        double middle_angle = middle_vec1.AngleTo(middle_vec2);
                        int middle_angleInt = (int)(thumb_angle / 3.1415926 * 180);
                        int middle_angleInterval = (thumb_angleInt / 30) + 1;

                        Leap.Vector ring_vec1 = new Leap.Vector((float)(ring_p2.x - ring_p1.x), (float)(ring_p2.y - ring_p1.y), (float)(ring_p2.z - ring_p1.z));
                        Leap.Vector ring_vec2 = new Leap.Vector((float)(ring_p0.x - ring_p1.x), (float)(ring_p0.y - ring_p1.y), (float)(ring_p0.z - ring_p1.z));
                        double ring_angle = ring_vec1.AngleTo(ring_vec2);
                        int ring_angleInt = (int)(ring_angle / 3.1415926 * 180);
                        int ring_angleInterval = (ring_angleInt / 30) + 1;

                        Leap.Vector pinky_vec1 = new Leap.Vector((float)(pinky_p2.x - pinky_p1.x), (float)(pinky_p2.y - pinky_p1.y), (float)(pinky_p2.z - pinky_p1.z));
                        Leap.Vector pinky_vec2 = new Leap.Vector((float)(pinky_p0.x - pinky_p1.x), (float)(pinky_p0.y - pinky_p1.y), (float)(pinky_p0.z - pinky_p1.z));
                        double pinky_angle = pinky_vec1.AngleTo(pinky_vec2);
                        int pinky_angleInt = (int)(pinky_angle / 3.1415926 * 180);
                        int pinky_angleInterval = (pinky_angleInt / 30) + 1;

                        Leap.Vector palm_vec1 = new Leap.Vector((float)(palm_p2.x - palm_p1.x), (float)(palm_p2.y - palm_p1.y), (float)(palm_p2.z - palm_p1.z));
                        Leap.Vector palm_vec2 = new Leap.Vector((float)(palm_p0.x - palm_p1.x), (float)(palm_p0.y - palm_p1.y), (float)(palm_p0.z - palm_p1.z));
                        double palm_angle = palm_vec1.AngleTo(palm_vec2);
                        int palm_angleInt = (int)(palm_angle / 3.1415926 * 180);
                        int palm_angleInterval = (palm_angleInt / 30) + 1;


                        string info2 = frameCount + "," + thumb_angleInt + "," + thumb_angleInterval + "," + thumb_v1
                            + "," + index_angleInt + "," + index_angleInterval + "," + index_v1
                            + "," + middle_angleInt + "," + middle_angleInterval + "," + middle_v1
                            + "," + ring_angleInt + "," + ring_angleInterval + "," + ring_v1
                            + "," + pinky_angleInt + "," + pinky_angleInterval + "," + pinky_v1
                            + "," + palm_angleInt + "," + palm_angleInterval + "," + palm_v1
                            + "," + DateTime.Now.ToString() + "\r\n";
                        fileWriter2.Write(info2);
                    }


                    //record history
                    thumb_p2.x = thumb_p1.x; thumb_p2.y = thumb_p1.y; thumb_p2.z = thumb_p1.z;
                    thumb_p1.x = thumb_p0.x; thumb_p1.y = thumb_p0.y; thumb_p1.z = thumb_p0.z;

                    index_p2.x = index_p1.x; index_p2.y = index_p1.y; index_p2.z = index_p1.z;
                    index_p1.x = index_p0.x; index_p1.y = index_p0.y; index_p1.z = index_p0.z;

                    middle_p2.x = middle_p1.x; middle_p2.y = middle_p1.y; middle_p2.z = middle_p1.z;
                    middle_p1.x = middle_p0.x; middle_p1.y = middle_p0.y; middle_p1.z = middle_p0.z;

                    ring_p2.x = ring_p1.x; ring_p2.y = ring_p1.y; ring_p2.z = ring_p1.z;
                    ring_p1.x = ring_p0.x; ring_p1.y = ring_p0.y; ring_p1.z = ring_p0.z;

                    pinky_p2.x = pinky_p1.x; pinky_p2.y = pinky_p1.y; pinky_p2.z = pinky_p1.z;
                    pinky_p1.x = pinky_p0.x; pinky_p1.y = pinky_p0.y; pinky_p1.z = pinky_p0.z;

                    palm_p2.x = palm_p1.x; palm_p2.y = palm_p1.y; palm_p2.z = palm_p1.z;
                    palm_p1.x = palm_p0.x; palm_p1.y = palm_p0.y; palm_p1.z = palm_p0.z;

                    thumb_v1 = thumb_v0;
                    index_v1 = index_v0;
                    middle_v1 = middle_v0;
                    ring_v1 = ring_v0;
                    pinky_v1 = pinky_v0;
                    palm_v1 = palm_v0;
                }
                else
                {
                    TobxLeft.Text = "左手未检测到";
                }


            }
            frameCount++;

            #endregion
        }

        private void captureBtn_Click(object sender, RoutedEventArgs e)
        {
            if (isRecording) //stop record
            {
                isRecording = false;
                captureBtn.Content = "点击开始采集";
                captureBtn.Background = System.Windows.Media.Brushes.White;
                //close
                fileWriter1.Close();
                fileWriter2.Close();
                HandFingerJointPositionFileWriter.Close();
                serialPort.Close();
                sampleNum++;
                if (sampleNum >= 20)
                {
                    sampleNum = 0;
                    MessageBox.Show("采集完成！");
                
                }

                sampleIndex.Text = (int.Parse(sampleIndex.Text)+1) .ToString();

            }
            else //start record
            {
                isRecording = true;
                captureBtn.Content = "点击完成采集";
                captureBtn.Background = System.Windows.Media.Brushes.Green;

                serialPort.Open();


                frameCount = 0;

                string fileName1 = "../../../DataSet/data1/" + "gesture" + gestureIndex.Text + "/" + "gesture" + gestureIndex.Text + "_subject" + subjetcIndex.Text + "_sample" + sampleIndex.Text + ".csv";
                string fileName2 = "../../../DataSet/data2/" + "gesture" + gestureIndex.Text + "/" + "gesture" + gestureIndex.Text + "_subject" + subjetcIndex.Text + "_sample" + sampleIndex.Text + ".csv";
                string filePath = "../../../../../DataSet/" + "HumanId" + subjetcIndex.Text + "/" + "HumanId" + subjetcIndex.Text + "GestureId" + gestureIndex.Text + "/Times" + sampleIndex.Text + "data.csv";
                string directoryPath = Path.GetDirectoryName(filePath);
                if (!Directory.Exists(directoryPath))
                {
                    Directory.CreateDirectory(directoryPath);
                }
                fileWriter1 = new StreamWriter(fileName1, true, Encoding.ASCII);
                fileWriter2 = new StreamWriter(fileName2, true, Encoding.ASCII);
                HandFingerJointPositionFileWriter = new StreamWriter(filePath, true, Encoding.ASCII);
                //write head
                string info1 = "frameIndex,thumb_x,thumb_y,thumb_z,thumb_v,index_x,index_y,index_z,index_v,middle_x,middle_y,middle_z,middle_v,ring_x,ring_y,ring_z,ring_v,pinky_x,pinky_y,pinky_z,pinky_v,palm_x,palm_y,palm_z,palm_v,date_now" + "\r\n";
                fileWriter1.Write(info1);
                string info2 = "frameIndex,thumb_angle,thumb_angle_interval,thumb_v,index_angle,index_angle_interval,index_v,middle_angle,middle_interval,middle_v,ring_angle,ring_interval,ring_v,pinky_angle,pinky_interval,pinky_v,palm_angle,palm_interval,palm_v,date_now" + "\r\n";
                fileWriter2.Write(info2);
            }

           
          
        }

        private void MainWindows_Keydown(object sender, KeyEventArgs e)
        {

            //判断用户的按键是否为Alt+F4
            if (e.KeyStates == Keyboard.GetKeyStates(Key.Space))
            {
                e.Handled = true;
                //MessageBox.Show("请输入密码！");
                captureBtn_Click(null,null);
            }
            if (e.Key == Key.Enter)
            {
                e.Handled = true;
                this.captureBtn_Click(sender, e);
            }

        }

        private void captureBtn_KeyDown(object sender, KeyEventArgs e)
        {
        }
    }
    class SampleListener
    {
        public void OnInit(Controller controller)
        {
            Console.WriteLine("Initialized");
        }

        public void OnConnect(object sender, DeviceEventArgs args)
        {
            Console.WriteLine("Connected");
        }

        public void OnDisconnect(object sender, DeviceEventArgs args)
        {
            Console.WriteLine("Disconnected");
          
        }

        public void OnServiceConnect(object sender, ConnectionEventArgs args)
        {
            Console.WriteLine("Service Connected");
        }

        public void OnServiceDisconnect(object sender, ConnectionLostEventArgs args)
        {
            Console.WriteLine("Service Disconnected");
        }

        public void OnServiceChange(Controller controller)
        {
            Console.WriteLine("Service Changed");
        }

        public void OnDeviceFailure(object sender, DeviceFailureEventArgs args)
        {
            Console.WriteLine("Device Error");
            Console.WriteLine("  PNP ID:" + args.DeviceSerialNumber);
            Console.WriteLine("  Failure message:" + args.ErrorMessage);
        }

        public void OnLogMessage(object sender, LogEventArgs args)
        {
            
        }
    }


}
