# -*- coding: utf-8 -*-
"""
Created on Mon Feb 27 17:37:38 2017

@author: SMukherjee
"""
import numpy
import h5py
import matplotlib.pyplot as plt
from sklearn import preprocessing, metrics
from sklearn.learning_curve import learning_curve


def traintest(freq,conv_group_L,no_group_L,conv_group_F,no_group_F,A,B):
# train and test data creation
    frequency = numpy.array([A, B])
    a, = numpy.where((freq>=frequency[0]) & (freq<=frequency[1]))
    
    conv = numpy.mean(conv_group_L[:,:,a,:],axis=2)
    no = numpy.mean(no_group_L[:,:,a,:],axis=2)
    
    Xtrain = numpy.concatenate((conv,no),axis=0)
    Ytrain = numpy.concatenate((numpy.ones(conv.shape[0]),numpy.ones(no.shape[0])+1),axis=0)
    
    
    conv = numpy.mean(conv_group_F[:,:,a,:],axis=2)
    no = numpy.mean(no_group_F[:,:,a,:],axis=2)
    
    Xtest = numpy.concatenate((conv,no),axis=0)
    Ytest = numpy.concatenate((numpy.ones(conv.shape[0]),numpy.ones(no.shape[0])+1),axis=0)
        
    Xtrain = Xtrain.reshape(Xtrain.shape[0],-1)
    Xtest = Xtest.reshape(Xtest.shape[0],-1)    
    
    return Xtrain,Ytrain,Xtest,Ytest

##########################################################################################################################
# loading data
mat = h5py.File('leaderFolower_conv_noch_python.mat')
conv_group_L = mat['conv_group_L']
conv_group_F = mat['conv_group_F']
no_group_L = mat['no_group_L']
no_group_F = mat['no_group_F']
freq = mat['freq']
time = mat['time']
channel = mat['channel']


conv_group_L = numpy.array(conv_group_L)
conv_group_F = numpy.array(conv_group_F)
no_group_L = numpy.array(no_group_L)
no_group_F = numpy.array(no_group_F)
freq = numpy.array(freq)
time = numpy.array(time)
channel = numpy.array(channel)

conv_group_L = numpy.rollaxis(numpy.rollaxis(numpy.rollaxis(conv_group_L, 3),3,1),3,2)
conv_group_F = numpy.rollaxis(numpy.rollaxis(numpy.rollaxis(conv_group_F, 3),3,1),3,2)
no_group_L = numpy.rollaxis(numpy.rollaxis(numpy.rollaxis(no_group_L, 3),3,1),3,2)
no_group_F = numpy.rollaxis(numpy.rollaxis(numpy.rollaxis(no_group_F, 3),3,1),3,2)

freq = numpy.concatenate( freq, axis=0 )
time = numpy.concatenate( time, axis=0 )
channel = numpy.concatenate( channel, axis=0 )

### train and test data creation
Xtrain,Ytrain,Xtest,Ytest = traintest(freq,conv_group_L,no_group_L,conv_group_F,no_group_F,11,15)



#----------------------------------------------------------------------------------------------------
#normalization of features
scale = preprocessing.StandardScaler().fit(Xtrain)
Xtrain = scale.transform(Xtrain)
Xtest = scale.transform(Xtest)

#--------------------------------------------classification-------------------------------------------
##GradientBoost
#from sklearn.ensemble import GradientBoostingClassifier
#clf = GradientBoostingClassifier(n_estimators=100, learning_rate=0.1, 
#                                     max_depth=1, random_state=0)

## SVM                                     
#from sklearn import svm
#clf = svm.SVC()

#from sklearn.multiclass import OneVsOneClassifier
#from sklearn.multiclass import OutputCodeClassifier
#clf = OutputCodeClassifier(svm.SVC())

## RandomForest
from sklearn.ensemble import RandomForestClassifier
clf = RandomForestClassifier(min_samples_leaf=10)

## SGD
#from sklearn.linear_model import SGDClassifier
#clf = SGDClassifier(loss="log", penalty="l2")

# CART
#from sklearn import tree
#clf = tree.DecisionTreeClassifier()
#
### AdaBoostClassifier
#from sklearn.ensemble import AdaBoostClassifier
#clf = AdaBoostClassifier(n_estimators=100)

#  Gaussian Naive Bayes
#from sklearn.naive_bayes import GaussianNB
#clf = GaussianNB()

# KNN
#from sklearn import neighbors
##clf = neighbors.KNeighborsClassifier(n_neighbors=10,weights='distance')
#clf = neighbors.KNeighborsClassifier(n_neighbors=10)


##-------------------------------------------------metrics------------------
clf = clf.fit(Xtrain, Ytrain)
print(metrics.classification_report(Ytest, clf.predict(Xtest)))

from sklearn.metrics import confusion_matrix
confusion_matrix(Ytest, clf.predict(Xtest))

from sklearn.metrics import cohen_kappa_score
cohen_kappa_score(Ytest, clf.predict(Xtest))
##--------------------------Crossvalidation 5 times using different split------------------------------
#from sklearn import cross_validation
#scores = cross_validation.cross_val_score(clf, XtrainAll, label, cv=3, scoring='f1')
#print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

####---------------------------------Check for overfeat-------------------------------------
train_sample_size, train_scores, test_scores = learning_curve(clf,Xtrain, Ytrain, cv=10)
#----------------------------------------Visualization---------------------------------------------
plt.xlabel("# Training sample")
plt.ylabel("Accuracy")
plt.grid();
mean_train_scores = numpy.mean(train_scores, axis=1)
mean_test_scores = numpy.mean(test_scores, axis=1)
std_train_scores = numpy.std(train_scores, axis=1)
std_test_scores = numpy.std(test_scores, axis=1)

gap = numpy.abs(mean_test_scores - mean_train_scores)
g = plt.figure(1)
plt.title("Learning curves for %r\n"
             "Best test score: %0.2f - Gap: %0.2f" %
             (clf, mean_test_scores.max(), gap[-1]))
plt.plot(train_sample_size, mean_train_scores, label="Training", color="b")
plt.fill_between(train_sample_size, mean_train_scores - std_train_scores,
                 mean_train_scores + std_train_scores, alpha=0.1, color="b")
plt.plot(train_sample_size, mean_test_scores, label="Cross-validation",
         color="g")
plt.fill_between(train_sample_size, mean_test_scores - std_test_scores,
                 mean_test_scores + std_test_scores, alpha=0.1, color="g")
plt.legend(loc="lower right")
g.show()




















