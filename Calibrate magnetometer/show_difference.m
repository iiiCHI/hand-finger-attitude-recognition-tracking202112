clear;clc

before = load('./_before.csv');
after = load('./_after.csv');

axis on;
scatter3(before(:,2),before(:,3),before(:,4),'filled','r');
hold on;
scatter3(after(:,2),after(:,3),after(:,4),'filled','g');