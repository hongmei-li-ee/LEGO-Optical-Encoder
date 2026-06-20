# 🔄 LEGO Optical Encoder

This project is a LEGO-based prototype of an optical rotary encoder used to measure rotational motion from a LEGO EV3 motor. The system converts mechanical rotation into digital pulse signals, which are analyzed in MATLAB to estimate angular position, velocity, and acceleration.

## 🎯 Objective
To build and test a simple optical encoder and process its signal using numerical methods.

## ⚙️ System
- LEGO EV3 motor with a rotating slotted disk (16 slots)
- Light source and light sensor for pulse detection
- MATLAB for signal processing and analysis

## 📊 Method
- Edge detection to identify pulses
- Numerical differentiation for angular velocity and acceleration
- Euler integration for angular position
- Low-pass filtering to reduce noise

## 🧠 Applications
Optical encoders are used in motor control, robotics, and automation systems for measuring position and speed.
---

Developed as a hands-on engineering exercise combining hardware and signal processing.
