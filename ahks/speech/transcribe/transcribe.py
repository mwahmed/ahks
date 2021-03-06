#!/bin/python

import google_speech as gs
import prepro as pp
import sys
import re
import os
import glob
import utils as ut
import argparse as ap
import pymongo
from pymongo import MongoClient
from bson.objectid import ObjectId

t_id = sys.argv[2]
client = MongoClient()
db = client.ahks_development
transcriptions = db.transcriptions

# a= t.find_one({"_id": ObjectId(str(t_id))})

DEBUG = ut.get_debug()

"""
Parses command line args and returns 
    list of parameters
@ret= List of paths to input file,
    output summary file, and segment directory
"""
def parse_args():    
    global DEBUG
    parser = ap.ArgumentParser()
    parser.add_argument("filepath", help="path to input audio file")
    parser.add_argument("trans_id", help="id in the database")
    parser.add_argument("-i", "--indir", help="directory containing input audio file, if filepath does not contain path")
    parser.add_argument("-d", "--debug", help="enble debugging output", type=bool)
    parser.add_argument("-s", "--sumpath", help="path to summary file. Can either be file or dir. If dir, summary file stored in dir/basefilename.txt")
    parser.add_argument("-f", "--segdir", help="directory to store temporary audio seg/frag-ment files")
    args = parser.parse_args()
    
    cfg_params = ut.get_cfg_params()
    
    filepath=""
    sumpath=""
    segdir=""
    
    #Get the input file path
    #FIX: Optimization, if os.path.isfile(args.filepath): filepath = args.filepath
    drct, fl = ut.split_path(args.filepath)
    if not drct:
        if args.indir and not os.path.isdir(args.indir):
            print "Invalid input directory specified"
            raise Exception
    if not fl:
        raise Exception
        print "Invalid input file specified"
    filepath = ut.dir_path( drct or args.indir or cfg_params["in_dir"] ) + fl
    
    if not os.path.exists(filepath):
        print "Input file not found. Filepath is {}".format(filepath)
        raise Exception    
    
    #Get summary file path    
    if args.sumpath:
        drct, fl = ut.split_path(args.sumpath)
        if drct and fl: sumpath = args.sumpath
        elif drct:
            sumpath = ut.dir_path(drct) + ut.base_filename(filepath)
        elif fl: 
            sumpath = ut.dir_path(cfg_params["summary_dir"]) + fl
        else:
            print "Invalid summary path specified"
            raise Exception
    else:
         sumpath = ut.dir_path(cfg_params["summary_dir"]) + ut.base_filename(filepath)
    #Append extension
    if sumpath[-5:] != ".smry" : sumpath += ".smry"
    
    #Get segment directory path           
    if args.segdir and not os.path.isdir(args.segdir):
        print "Invalid segment file directory specified"
        raise Exception
    segdir = ut.dir_path(args.segdir or cfg_params["seg_file_dir"])  
    
    #Set Debug flag
    if args.debug:
        DEBUG = args.debug 
    
    return (filepath, sumpath, segdir)

"""
Transcribes the audio at filepatha
@params
    filepath - the path to the audio file
        to be transcribed
    sumpath - path to file to write summary in
    segdir - directory to store temporary segment files
@ret = list of transcribed lines
"""    
def transcribe(filepath, sumpath, segdir):
    if DEBUG: print "filepath= {}, sumpath= {}, segdir= {}".format(filepath, sumpath, segdir)
    if DEBUG: print "File length = {}".format(ut.file_length(filepath))     
    
    #Writes all segment files to segdir
    seg_count = pp.prepro2(filepath, segdir)           
    
    basefile = ut.base_filename(filepath)       
    if DEBUG: print "basefile is {}".format(basefile)
    trans_list = []
    sf = open(sumpath, "w")
    #Consider using #while os.path.exists(opath): 
    segfiles = (ut.dir_path(segdir) + basefile + "__" + str(i) + ".flac" for i in range(seg_count))    
    
    db_data = ""
    for seg in segfiles:     
        if DEBUG: print "segment path is {}".format(seg)
        trans = gs.key_trans(seg)
        print "trans is: " + trans
        sf.write(trans + "\n")
        
        db_data += str(trans) + "\n"

        if DEBUG: print(trans)
        trans_list.append(trans)         
    
    sf.close()
    
    ut.remove_seg_files(segdir, basefile + "__*.flac")
    return db_data

if __name__ == "__main__":      
    filepath, sumpath, segdir = parse_args()
    data = transcribe(filepath, sumpath, segdir)
    transcriptions.update({"_id":ObjectId(str(t_id))},{"$set":{"text":str(data)} })
