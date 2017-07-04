#import "prsa.h"
const char *base64_char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
const char *base64_url  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*$=";
unsigned char r_base64_url[] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,0,0,0,0,0,62,0,0,0,0,0,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0,0,0};

//only used to generate r_base64_url array.
+ (void) print_base_reverse_string{
    unsigned char * d = (unsigned char *)malloc(130);
    memset(d,0,130);
    for(int i=0;i<64;i++){
        d[(unsigned char)base64_url[i]]=i;
        //printf("%d_",(int)base64_url[i]);
    }
    //printf("%s",d);
    return;
}

+ (NSString *)base64:(NSData *) data
{
    unsigned char * s = (unsigned char *)[data bytes];
    int len = [data length],i=0,k=0;
    int t;
    unsigned char * d = (unsigned char *)malloc((len/3+1)*4 + 1);
    
    for(i=2,k=3;i<=len/3*3;i=i+3,k=k+4)
    {
        //mapping to bytes
        t=((s[i-2]>>2)&0x3f);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2])<<4)&0x30) + ((s[i-1]>>4)&0x0f);
        d[k-2]=base64_url[t];
        
        t=((s[i-1]<<2)&0x3c) + ((s[i]>>6)&0x03);
        d[k-1]=base64_url[t];
        
        t=((s[i])&0x3f);
        d[k]=base64_url[t];
    }
    d[k-3]=0;
    // if some left, mapping it.( separate the code to avoid if in 'for loop')
    if(len%3==1){
        // 1 byte
        t=((s[i-2]>>2)&0x3f);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2])<<4)&0x30);
        d[k-2]=base64_url[t];
        
        d[k-1]=base64_url[64];
        d[k]=base64_url[64];
        d[k+1]=0;
    }else if(len%3==2){
        t=((s[i-2]>>2)&0x3f);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2])<<4)&0x30) + ((s[i-1]>>4)&0x0f);
        d[k-2]=base64_url[t];
        
        t=((s[i-1]<<2)&0x3c);
        d[k-1]=base64_url[t];
        d[k]=base64_url[64];
        d[k+1]=0;
    }
    
//    [Prsa print_chars:d length:k+1];
    return [[NSString alloc] initWithUTF8String:(char *)d];
}

+ (NSData *)from_base64:(NSString *) data
{
    int len = [data length],plen=0;
    //remove '='
    const char * td = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char * d = (unsigned char *)malloc((len/4+1)*3); // add space for the last '\0'
    for(int i=0;i<4;i++){
        if(td[len-1]=='='){
            len = len-1;
        }
    }
    //plen is to decide the exactly length of the return data.
    
    int t1,t2,t3,t4,i,j;
    for(i=3,j=2;i<=len/4*4;i=i+4,j=j+3)
    {
        //4 char into 3 Byte
        t1 = r_base64_url[(unsigned char)td[i-3]];
        t2 = r_base64_url[(unsigned char)td[i-2]];
        t3 = r_base64_url[(unsigned char)td[i-1]];
        t4 = r_base64_url[(unsigned char)td[i]];
        d[j-2]=((t1<<2)&0xfc)+((t2>>4)&0x03);
        d[j-1]=((t2<<4)&0xf0)+((t3>>2)&0x0f);
        d[j]=((t3<<6)&0xc0)+((t4)&0x3f);
    }
    plen = j-2;
    // the reason to separate the len%4 !=0 is to avoid if statement in 'for loop'.
    if(len%4==1){
        //failed
    }else if(len%4==2){
        t1 = r_base64_url[(unsigned char)td[i-3]];
        t2 = r_base64_url[(unsigned char)td[i-2]];
        t3 = r_base64_url[(unsigned char)td[i-1]];
        d[j-2]=((t1<<2)&0xfc)+((t2>>4)&0x03);
        plen = j-1;
    }else if(len%4==3){
        t1 = r_base64_url[(unsigned char)td[i-3]];
        t2 = r_base64_url[(unsigned char)td[i-2]];
        t3 = r_base64_url[(unsigned char)td[i-1]];
        d[j-2]=((t1<<2)&0xfc)+((t2>>4)&0x03);
        d[j-1]=((t2<<4)&0xf0)+((t3>>2)&0x0f);
        plen = j;
    }
    NSData *ret = [[NSData alloc] initWithBytes:d length:plen];
    return ret;
}
