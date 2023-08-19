# Importing the module
import os

# Getting the current working directory
cwd = os.getcwd()

# Printing the current working directory
print("The Current working directory is: {0}".format(cwd))

# Printing the type of the returned object
print("os.getcwd() returns an object of type: {0}".format(type(cwd)))

# Changing the current working directory
os.chdir('C:\\Users\\jamel\\Dropbox\\Documents\\Wolfram Mathematica\\Webinars\\WolframLanguageForPythonUsers\\WolframLanguageForPythonUsers\\')

# Print the current working directory
print("The Current working directory now is: {0}".format(os.getcwd()))

