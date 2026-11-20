using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

namespace ShutdownWidget
{
    public partial class Form1 : Form
    {
        private System.Windows.Forms.Timer countdownTimer;
        private TimeSpan remainingTime;
        private bool isCountingDown = false;
        private NotifyIcon trayIcon;
        private ContextMenuStrip trayMenu;

        // UI Controls
        private NumericUpDown numHours;
        private NumericUpDown numMinutes;
        private NumericUpDown numSeconds;
        private ComboBox cmbAction;
        private Button btnStart;
        private Button btnStop;
        private Label lblCountdown;
        private Label lblStatus;
        private GroupBox grpTimer;
        private GroupBox grpAction;
        private CheckBox chkMinimizeToTray;
        private CheckBox chkForceClose;

        public Form1()
        {
            InitializeComponent();
            SetupCustomUI();
            SetupTrayIcon();
            SetupCountdownTimer();
        }

        private void SetupCustomUI()
        {
            this.Text = "Windows Shutdown Timer";
            this.ClientSize = new Size(370, 420);
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.StartPosition = FormStartPosition.CenterScreen;
            
            // Load custom icon from embedded resource
            this.Icon = LoadAppIcon();

            // Timer Group
            grpTimer = new GroupBox
            {
                Text = "Set Timer",
                Location = new Point(15, 15),
                Size = new Size(340, 100),
                Font = new Font("Segoe UI", 9)
            };
            this.Controls.Add(grpTimer);

            // Hours (0-110)
            var lblHours = new Label { Text = "Hours:", Location = new Point(15, 30), AutoSize = true, Font = new Font("Segoe UI", 9) };
            numHours = new NumericUpDown
            {
                Location = new Point(55, 27),
                Size = new Size(55, 25),
                Minimum = 0,
                Maximum = 99,
                Value = 0,
                Font = new Font("Segoe UI", 10)
            };
            grpTimer.Controls.Add(lblHours);
            grpTimer.Controls.Add(numHours);

            // Minutes (110-220)
            var lblMinutes = new Label { Text = "Min:", Location = new Point(115, 30), AutoSize = true, Font = new Font("Segoe UI", 9) };
            numMinutes = new NumericUpDown
            {
                Location = new Point(150, 27),
                Size = new Size(55, 25),
                Minimum = 0,
                Maximum = 59,
                Value = 30,
                Font = new Font("Segoe UI", 10)
            };
            grpTimer.Controls.Add(lblMinutes);
            grpTimer.Controls.Add(numMinutes);

            // Seconds (220-330)
            var lblSeconds = new Label { Text = "Sec:", Location = new Point(215, 30), AutoSize = true, Font = new Font("Segoe UI", 9) };
            numSeconds = new NumericUpDown
            {
                Location = new Point(245, 27),
                Size = new Size(55, 25),
                Minimum = 0,
                Maximum = 59,
                Value = 0,
                Font = new Font("Segoe UI", 10)
            };
            grpTimer.Controls.Add(lblSeconds);
            grpTimer.Controls.Add(numSeconds);

            // Preset buttons
            var btnPreset10m = new Button { Text = "10 min", Location = new Point(15, 65), Size = new Size(65, 23), Font = new Font("Segoe UI", 8) };
            btnPreset10m.Click += (s, e) => { numHours.Value = 0; numMinutes.Value = 10; numSeconds.Value = 0; };
            grpTimer.Controls.Add(btnPreset10m);

            var btnPreset30m = new Button { Text = "30 min", Location = new Point(85, 65), Size = new Size(65, 23), Font = new Font("Segoe UI", 8) };
            btnPreset30m.Click += (s, e) => { numHours.Value = 0; numMinutes.Value = 30; numSeconds.Value = 0; };
            grpTimer.Controls.Add(btnPreset30m);

            var btnPreset1h = new Button { Text = "1 hour", Location = new Point(155, 65), Size = new Size(65, 23), Font = new Font("Segoe UI", 8) };
            btnPreset1h.Click += (s, e) => { numHours.Value = 1; numMinutes.Value = 0; numSeconds.Value = 0; };
            grpTimer.Controls.Add(btnPreset1h);

            var btnPreset2h = new Button { Text = "2 hours", Location = new Point(225, 65), Size = new Size(65, 23), Font = new Font("Segoe UI", 8) };
            btnPreset2h.Click += (s, e) => { numHours.Value = 2; numMinutes.Value = 0; numSeconds.Value = 0; };
            grpTimer.Controls.Add(btnPreset2h);

            // Action Group
            grpAction = new GroupBox
            {
                Text = "Action",
                Location = new Point(15, 125),
                Size = new Size(340, 110),
                Font = new Font("Segoe UI", 9)
            };
            this.Controls.Add(grpAction);

            cmbAction = new ComboBox
            {
                Location = new Point(15, 30),
                Size = new Size(300, 25),
                DropDownStyle = ComboBoxStyle.DropDownList,
                Font = new Font("Segoe UI", 10)
            };
            cmbAction.Items.AddRange(new object[] {
                "Shutdown",
                "Restart",
                "Sleep",
                "Hibernate",
                "Sign Out",
                "Lock Workstation"
            });
            cmbAction.SelectedIndex = 0;
            grpAction.Controls.Add(cmbAction);

            chkForceClose = new CheckBox
            {
                Text = "Force close apps (no prompt)",
                Location = new Point(15, 65),
                AutoSize = true,
                Font = new Font("Segoe UI", 9),
                Checked = false
            };
            grpAction.Controls.Add(chkForceClose);

            chkMinimizeToTray = new CheckBox
            {
                Text = "Minimize to tray when started",
                Location = new Point(15, 90),
                AutoSize = true,
                Font = new Font("Segoe UI", 9),
                Checked = true
            };
            grpAction.Controls.Add(chkMinimizeToTray);

            // Countdown Display
            lblCountdown = new Label
            {
                Text = "00:00:00",
                Location = new Point(15, 250),
                Size = new Size(340, 70),
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Consolas", 32, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 120, 215),
                BorderStyle = BorderStyle.FixedSingle,
                BackColor = Color.FromArgb(240, 245, 250)
            };
            this.Controls.Add(lblCountdown);

            // Status Label
            lblStatus = new Label
            {
                Text = "Ready",
                Location = new Point(15, 330),
                Size = new Size(340, 25),
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Segoe UI", 9),
                ForeColor = Color.Gray
            };
            this.Controls.Add(lblStatus);

            // Buttons
            btnStart = new Button
            {
                Text = "Start Timer",
                Location = new Point(15, 365),
                Size = new Size(165, 40),
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnStart.FlatAppearance.BorderSize = 0;
            btnStart.Click += BtnStart_Click;
            this.Controls.Add(btnStart);

            btnStop = new Button
            {
                Text = "Cancel",
                Location = new Point(190, 365),
                Size = new Size(165, 40),
                Font = new Font("Segoe UI", 10),
                BackColor = Color.FromArgb(200, 60, 60),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand,
                Enabled = false
            };
            btnStop.FlatAppearance.BorderSize = 0;
            btnStop.Click += BtnStop_Click;
            this.Controls.Add(btnStop);

            // Credit Label
            var lblCredit = new Label
            {
                Text = "Created By Rez Ren",
                Location = new Point(15, 410),
                Size = new Size(340, 20),
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Segoe UI", 7.5f, FontStyle.Italic),
                ForeColor = Color.FromArgb(160, 160, 160)
            };
            this.Controls.Add(lblCredit);

            // Handle form closing
            this.FormClosing += Form1_FormClosing;
            this.Resize += Form1_Resize;
        }

        private void SetupTrayIcon()
        {
            trayMenu = new ContextMenuStrip();
            trayMenu.Items.Add("Open", null, (s, e) => ShowFromTray());
            trayMenu.Items.Add("Cancel Timer", null, (s, e) => CancelTimer());
            trayMenu.Items.Add("-");
            trayMenu.Items.Add("Exit", null, (s, e) => Application.Exit());

            trayIcon = new NotifyIcon
            {
                Icon = LoadAppIcon(),
                Text = "Shutdown Timer - Ready",
                Visible = false,
                ContextMenuStrip = trayMenu
            };
            trayIcon.DoubleClick += (s, e) => ShowFromTray();
        }

        private Icon LoadAppIcon()
        {
            try
            {
                var assembly = Assembly.GetExecutingAssembly();
                
                // Try embedded PNG resource (for single-file publish) - chronometer.png linked as icon.png
                string pngResourceName = "ShutdownWidget.icon.png";
                using (var stream = assembly.GetManifestResourceStream(pngResourceName))
                {
                    if (stream != null)
                    {
                        using (var bitmap = new Bitmap(stream))
                        {
                            return Icon.FromHandle(bitmap.GetHicon());
                        }
                    }
                }
                
                // Fallback to PNG file (for development/debug)
                string pngPath = Path.Combine(Application.StartupPath, "icon.png");
                if (File.Exists(pngPath))
                {
                    using (var bitmap = new Bitmap(pngPath))
                    {
                        return Icon.FromHandle(bitmap.GetHicon());
                    }
                }
                
                // Fallback to ICO file
                string icoPath = Path.Combine(Application.StartupPath, "icon.ico");
                if (File.Exists(icoPath))
                {
                    return new Icon(icoPath);
                }
            }
            catch { }
            return SystemIcons.Shield;
        }

        private void SetupCountdownTimer()
        {
            countdownTimer = new System.Windows.Forms.Timer
            {
                Interval = 1000
            };
            countdownTimer.Tick += CountdownTimer_Tick;
        }

        private void BtnStart_Click(object sender, EventArgs e)
        {
            int hours = (int)numHours.Value;
            int minutes = (int)numMinutes.Value;
            int seconds = (int)numSeconds.Value;

            if (hours == 0 && minutes == 0 && seconds == 0)
            {
                MessageBox.Show("Please set a timer greater than 0.", "Invalid Timer", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            remainingTime = new TimeSpan(hours, minutes, seconds);
            isCountingDown = true;

            UpdateUIForCountdown(true);
            countdownTimer.Start();
            UpdateCountdownDisplay();

            if (chkMinimizeToTray.Checked)
            {
                MinimizeToTray();
            }

            lblStatus.Text = $"Timer started - {cmbAction.SelectedItem} in {remainingTime:hh\\:mm\\:ss}";
            lblStatus.ForeColor = Color.Green;
        }

        private void BtnStop_Click(object sender, EventArgs e)
        {
            CancelTimer();
        }

        private void CancelTimer()
        {
            countdownTimer.Stop();
            isCountingDown = false;
            UpdateUIForCountdown(false);
            lblCountdown.Text = "00:00:00";
            lblCountdown.ForeColor = Color.FromArgb(0, 120, 215);
            lblStatus.Text = "Timer cancelled";
            lblStatus.ForeColor = Color.Gray;
            trayIcon.Text = "Shutdown Timer - Ready";
            trayIcon.Visible = false;
            this.ShowInTaskbar = true;
        }

        private void CountdownTimer_Tick(object sender, EventArgs e)
        {
            if (remainingTime.TotalSeconds <= 1)
            {
                countdownTimer.Stop();
                ExecuteAction();
                return;
            }

            remainingTime = remainingTime.Subtract(TimeSpan.FromSeconds(1));
            UpdateCountdownDisplay();

            // Change color when less than 1 minute
            if (remainingTime.TotalMinutes < 1)
            {
                lblCountdown.ForeColor = Color.Red;
            }
            else if (remainingTime.TotalMinutes < 5)
            {
                lblCountdown.ForeColor = Color.Orange;
            }
        }

        private void UpdateCountdownDisplay()
        {
            lblCountdown.Text = remainingTime.ToString(@"hh\:mm\:ss");
            trayIcon.Text = $"Shutdown Timer - {remainingTime:hh\\:mm\\:ss} remaining";
        }

        private void UpdateUIForCountdown(bool counting)
        {
            numHours.Enabled = !counting;
            numMinutes.Enabled = !counting;
            numSeconds.Enabled = !counting;
            cmbAction.Enabled = !counting;
            chkForceClose.Enabled = !counting;
            btnStart.Enabled = !counting;
            btnStop.Enabled = counting;
            grpTimer.Enabled = !counting;
            grpAction.Enabled = !counting;
        }

        private void ExecuteAction()
        {
            isCountingDown = false;
            UpdateUIForCountdown(false);
            lblCountdown.Text = "00:00:00";
            lblCountdown.ForeColor = Color.FromArgb(0, 120, 215);

            string action = cmbAction.SelectedItem?.ToString() ?? "Shutdown";
            bool force = chkForceClose.Checked;

            try
            {
                string arguments = GetShutdownArguments(action, force);
                Process.Start(new ProcessStartInfo
                {
                    FileName = "shutdown.exe",
                    Arguments = arguments,
                    UseShellExecute = false,
                    CreateNoWindow = true
                });

                lblStatus.Text = $"{action} initiated...";
                lblStatus.ForeColor = Color.Green;

                // Auto-close after action (optional)
                if (chkMinimizeToTray.Checked)
                {
                    trayIcon.Visible = false;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to execute {action}: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                lblStatus.Text = "Error executing action";
                lblStatus.ForeColor = Color.Red;
            }
        }

        private string GetShutdownArguments(string action, bool force)
        {
            string forceFlag = force ? "/f " : "";
            
            switch (action)
            {
                case "Shutdown":
                    return $"/s {forceFlag}/t 0";
                case "Restart":
                    return $"/r {forceFlag}/t 0";
                case "Sleep":
                    return "/h /t 0"; // Hibernate is used for sleep in shutdown.exe
                case "Hibernate":
                    return "/h /t 0";
                case "Sign Out":
                    return $"/l {forceFlag}";
                case "Lock Workstation":
                    // Lock doesn't use shutdown.exe
                    LockWorkStation();
                    return "";
                default:
                    return $"/s {forceFlag}/t 0";
            }
        }

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern bool LockWorkStation();

        private void MinimizeToTray()
        {
            this.Hide();
            this.ShowInTaskbar = false;
            trayIcon.Visible = true;
            trayIcon.ShowBalloonTip(2000, "Shutdown Timer", $"Timer running in background. {remainingTime:hh\\:mm\\:ss} until {cmbAction.SelectedItem}.", ToolTipIcon.Info);
        }

        private void ShowFromTray()
        {
            this.Show();
            this.WindowState = FormWindowState.Normal;
            this.ShowInTaskbar = true;
            this.BringToFront();
            trayIcon.Visible = false;
        }

        private void Form1_Resize(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Minimized && chkMinimizeToTray.Checked && isCountingDown)
            {
                MinimizeToTray();
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (isCountingDown)
            {
                var result = MessageBox.Show(
                    "A timer is running. Minimize to tray instead of closing?",
                    "Timer Running",
                    MessageBoxButtons.YesNoCancel,
                    MessageBoxIcon.Question);

                if (result == DialogResult.Yes)
                {
                    e.Cancel = true;
                    MinimizeToTray();
                }
                else if (result == DialogResult.Cancel)
                {
                    e.Cancel = true;
                }
                // No = allow close (will cancel timer in Dispose)
            }

            if (!e.Cancel)
            {
                trayIcon?.Dispose();
                countdownTimer?.Dispose();
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                countdownTimer?.Stop();
                countdownTimer?.Dispose();
                trayIcon?.Dispose();
                trayMenu?.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}