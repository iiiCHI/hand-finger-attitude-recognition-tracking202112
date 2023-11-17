# app version
# v1.1, 20230625.

# Created by haipeng.wang@gmail.com
# v1.1, 20230215, remove experiment and condition variables.
# v1.0, 20221212, full functions finshed.
# v0.1, 20221212

# requirements
# 1 gender, age, handedness, visual acuity, prior experience with techniques related to the research.
# please indicate your age:

# You MUST customize the filename and the "header" info before using the scale.

import os
from appJar import gui

## data filename.
fname = "demographic_g2g-V.txt"

# texts = ["Ease of use",
#          "Fluidity", 
#          "Ease of learning"]

## Called when the submit button is clicked
def on_submit():
    if not os.path.exists(fname):
        # define header of log file.
        header = '# ' + 'uid ' + 'gender ' + 'age ' + 'experience-display ' + 'experience-gesture ' + 'experience-cross-device'
        file_handle = open(fname, "a")
        file_handle.write(header + '\n')
        file_handle.close()        
        
    user_id = app.getSpinBox("User ID")
        
    file_handle = open(fname, "a")

    write_string = ''
    write_string += str(user_id) + ' '
    write_string += app.getRadioButton("gender") + ' '
    write_string += str(int(app.getEntry("age"))) + ' '
    write_string += app.getRadioButton("display") + ' '
    write_string += app.getRadioButton("gesture")
    
    file_handle.write(write_string + '\n')
    file_handle.close()
    
    app.infoBox("Input", "Input successfully.")

def on_exit():
    app.stop()


## Main entry point
app = gui()
# app.showSplash("Questionnaire", fill='red', stripe='black', fg='white', font=44)
app.setTitle("Demographic")
app.setSize(1100, 700)
app.setFont(size=16, weight="bold")

app.setSticky("we")
app.addLabelSpinBoxRange("User ID", 1, 100, 0, 0)
# app.addHorizontalSeparator(1, 0, 3)

## Basic info of participants
app.startLabelFrame("Basic Info", colspan=6)
app.setSticky("w")
app.addLabel("genderLabel", "Your gender: ", column=0)
app.addRadioButton("gender", "Male", row="previous", column=1)
app.addRadioButton("gender", "Female", row="previous", column=2)

app.addLabel("Your age: ")
app.addNumericEntry("age", row="previous", column=1)
app.stopLabelFrame()

## Human Factors

## prior experience 
app.startLabelFrame("Prior Experience", colspan=6)
app.addLabel("Which hand is your handness: ", column=0)
app.addRadioButton("display", "Daily", row="previous", column=1)
app.addRadioButton("display", "Weekly", row="previous", column=2)
app.addRadioButton("display", "Monthly", row="previous", column=3)
app.addRadioButton("display", "Yearly", row="previous", column=4)
app.addRadioButton("display", "Never", row="previous", column=5)

app.addLabel("Your prior experience with Gesture Interaction: ", column=0)
app.addRadioButton("gesture", "Left hand", row="previous", column=1)
app.addRadioButton("gesture", "Right hand", row="previous", column=2)
app.addRadioButton("gesture", "Both", row="previous", column=3)
app.addRadioButton("gesture", "Neither", row="previous", column=4)
app.addRadioButton("gesture", "", row="previous", column=5)

app.stopLabelFrame()

app.setSticky("we")
row = app.getRow()
app.addButton("Exit", on_exit, column=0)
app.addButton("Submit", on_submit, row="previous", column=2)

app.go()


