using System;
using System.Windows.Forms;

namespace Tremors
{
    partial class Form1
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.label1 = new System.Windows.Forms.Label();
            this.hand_point = new System.Windows.Forms.PictureBox();
            this.panel_act = new System.Windows.Forms.Panel();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.label_act = new System.Windows.Forms.Label();
            this.panel_rst = new System.Windows.Forms.Panel();
            this.label_rst3 = new System.Windows.Forms.Label();
            this.label_rst2 = new System.Windows.Forms.Label();
            this.label_rst1 = new System.Windows.Forms.Label();
            this.panel_target = new System.Windows.Forms.Panel();
            this.label_target3 = new System.Windows.Forms.Label();
            this.label_target2 = new System.Windows.Forms.Label();
            this.label_target1 = new System.Windows.Forms.Label();
            this.label_none = new System.Windows.Forms.Label();
            this.progressBar2 = new System.Windows.Forms.ProgressBar();
            ((System.ComponentModel.ISupportInitialize)(this.hand_point)).BeginInit();
            this.panel_act.SuspendLayout();
            this.panel_rst.SuspendLayout();
            this.panel_target.SuspendLayout();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(1848, 1049);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(35, 12);
            this.label1.TabIndex = 0;
            this.label1.Text = "第1轮";
            // 
            // hand_point
            // 
            this.hand_point.BackColor = System.Drawing.Color.MistyRose;
            this.hand_point.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("hand_point.BackgroundImage")));
            this.hand_point.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.hand_point.Image = ((System.Drawing.Image)(resources.GetObject("hand_point.Image")));
            this.hand_point.Location = new System.Drawing.Point(532, 898);
            this.hand_point.Name = "hand_point";
            this.hand_point.Size = new System.Drawing.Size(46, 46);
            this.hand_point.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.hand_point.TabIndex = 1;
            this.hand_point.TabStop = false;
            this.hand_point.Visible = false;
            // 
            // panel_act
            // 
            this.panel_act.BackColor = System.Drawing.SystemColors.Window;
            this.panel_act.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panel_act.Controls.Add(this.progressBar1);
            this.panel_act.Controls.Add(this.label_act);
            this.panel_act.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel_act.Location = new System.Drawing.Point(0, 0);
            this.panel_act.Name = "panel_act";
            this.panel_act.Size = new System.Drawing.Size(1904, 523);
            this.panel_act.TabIndex = 2;
            // 
            // progressBar1
            // 
            this.progressBar1.BackColor = System.Drawing.Color.Red;
            this.progressBar1.Location = new System.Drawing.Point(363, -2);
            this.progressBar1.Maximum = 700;
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(10, 10);
            this.progressBar1.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.progressBar1.TabIndex = 1;
            this.progressBar1.Visible = false;
            // 
            // label_act
            // 
            this.label_act.AutoSize = true;
            this.label_act.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_act.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_act.Location = new System.Drawing.Point(842, 32);
            this.label_act.Name = "label_act";
            this.label_act.Size = new System.Drawing.Size(274, 80);
            this.label_act.TabIndex = 0;
            this.label_act.Text = "交互区";
            // 
            // panel_rst
            // 
            this.panel_rst.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(224)))), ((int)(((byte)(192)))));
            this.panel_rst.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel_rst.Controls.Add(this.label_rst3);
            this.panel_rst.Controls.Add(this.label_rst2);
            this.panel_rst.Controls.Add(this.label_rst1);
            this.panel_rst.Location = new System.Drawing.Point(1, 1);
            this.panel_rst.Name = "panel_rst";
            this.panel_rst.Size = new System.Drawing.Size(367, 523);
            this.panel_rst.TabIndex = 3;
            this.panel_rst.MouseHover += new System.EventHandler(this.panel_rst_MouseHover);
            // 
            // label_rst3
            // 
            this.label_rst3.AutoSize = true;
            this.label_rst3.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_rst3.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_rst3.Location = new System.Drawing.Point(115, 321);
            this.label_rst3.Name = "label_rst3";
            this.label_rst3.Size = new System.Drawing.Size(114, 80);
            this.label_rst3.TabIndex = 0;
            this.label_rst3.Text = "区";
            this.label_rst3.MouseHover += new System.EventHandler(this.panel_rst_MouseHover);
            // 
            // label_rst2
            // 
            this.label_rst2.AutoSize = true;
            this.label_rst2.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_rst2.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_rst2.Location = new System.Drawing.Point(115, 185);
            this.label_rst2.Name = "label_rst2";
            this.label_rst2.Size = new System.Drawing.Size(114, 80);
            this.label_rst2.TabIndex = 0;
            this.label_rst2.Text = "始";
            this.label_rst2.MouseHover += new System.EventHandler(this.panel_rst_MouseHover);
            // 
            // label_rst1
            // 
            this.label_rst1.AutoSize = true;
            this.label_rst1.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_rst1.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_rst1.Location = new System.Drawing.Point(115, 55);
            this.label_rst1.Name = "label_rst1";
            this.label_rst1.Size = new System.Drawing.Size(114, 80);
            this.label_rst1.TabIndex = 0;
            this.label_rst1.Text = "起";
            this.label_rst1.MouseHover += new System.EventHandler(this.panel_rst_MouseHover);
            // 
            // panel_target
            // 
            this.panel_target.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(255)))), ((int)(((byte)(128)))));
            this.panel_target.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel_target.Controls.Add(this.label_target3);
            this.panel_target.Controls.Add(this.label_target2);
            this.panel_target.Controls.Add(this.label_target1);
            this.panel_target.Location = new System.Drawing.Point(1666, 1);
            this.panel_target.Name = "panel_target";
            this.panel_target.Size = new System.Drawing.Size(240, 523);
            this.panel_target.TabIndex = 4;
            this.panel_target.Paint += new System.Windows.Forms.PaintEventHandler(this.panel1_Paint);
            this.panel_target.MouseEnter += new System.EventHandler(this.panel_target_MouseEnter);
            this.panel_target.MouseHover += new System.EventHandler(this.panel_target_MouseHover);
            // 
            // label_target3
            // 
            this.label_target3.AutoSize = true;
            this.label_target3.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_target3.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_target3.Location = new System.Drawing.Point(58, 321);
            this.label_target3.Name = "label_target3";
            this.label_target3.Size = new System.Drawing.Size(114, 80);
            this.label_target3.TabIndex = 0;
            this.label_target3.Text = "区";
            this.label_target3.MouseHover += new System.EventHandler(this.panel_target_MouseHover);
            // 
            // label_target2
            // 
            this.label_target2.AutoSize = true;
            this.label_target2.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_target2.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_target2.Location = new System.Drawing.Point(58, 185);
            this.label_target2.Margin = new System.Windows.Forms.Padding(30);
            this.label_target2.Name = "label_target2";
            this.label_target2.Size = new System.Drawing.Size(114, 80);
            this.label_target2.TabIndex = 0;
            this.label_target2.Text = "标";
            this.label_target2.MouseHover += new System.EventHandler(this.panel_target_MouseHover);
            // 
            // label_target1
            // 
            this.label_target1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.label_target1.AutoSize = true;
            this.label_target1.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_target1.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_target1.Location = new System.Drawing.Point(58, 55);
            this.label_target1.Margin = new System.Windows.Forms.Padding(3);
            this.label_target1.Name = "label_target1";
            this.label_target1.Size = new System.Drawing.Size(114, 80);
            this.label_target1.TabIndex = 0;
            this.label_target1.Text = "目";
            this.label_target1.MouseHover += new System.EventHandler(this.panel_target_MouseHover);
            // 
            // label_none
            // 
            this.label_none.AutoSize = true;
            this.label_none.Font = new System.Drawing.Font("楷体", 60F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label_none.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.label_none.Location = new System.Drawing.Point(801, 898);
            this.label_none.Name = "label_none";
            this.label_none.Size = new System.Drawing.Size(354, 80);
            this.label_none.TabIndex = 0;
            this.label_none.Text = "非交互区";
            // 
            // progressBar2
            // 
            this.progressBar2.BackColor = System.Drawing.Color.Red;
            this.progressBar2.Location = new System.Drawing.Point(0, 1064);
            this.progressBar2.Maximum = 700;
            this.progressBar2.Name = "progressBar2";
            this.progressBar2.Size = new System.Drawing.Size(1903, 10);
            this.progressBar2.Step = 100;
            this.progressBar2.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.progressBar2.TabIndex = 1;
            this.progressBar2.Visible = false;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.GradientInactiveCaption;
            this.ClientSize = new System.Drawing.Size(1904, 1078);
            this.Controls.Add(this.progressBar2);
            this.Controls.Add(this.label_none);
            this.Controls.Add(this.panel_target);
            this.Controls.Add(this.panel_rst);
            this.Controls.Add(this.panel_act);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.hand_point);
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.Form1_KeyDown);
            ((System.ComponentModel.ISupportInitialize)(this.hand_point)).EndInit();
            this.panel_act.ResumeLayout(false);
            this.panel_act.PerformLayout();
            this.panel_rst.ResumeLayout(false);
            this.panel_rst.PerformLayout();
            this.panel_target.ResumeLayout(false);
            this.panel_target.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }
        
        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel_act;
        private System.Windows.Forms.Panel panel_rst;
        private System.Windows.Forms.Panel panel_target;
        private System.Windows.Forms.Label label_target1;
        public System.Windows.Forms.PictureBox hand_point;
        private System.Windows.Forms.Label label_act;
        private System.Windows.Forms.Label label_rst3;
        private System.Windows.Forms.Label label_rst2;
        private System.Windows.Forms.Label label_rst1;
        private System.Windows.Forms.Label label_target3;
        private System.Windows.Forms.Label label_target2;
        private System.Windows.Forms.Label label_none;
        private System.Windows.Forms.ProgressBar progressBar1;
        private ProgressBar progressBar2;
    }
}

