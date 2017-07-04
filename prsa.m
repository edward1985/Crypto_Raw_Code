#import "prsa.h"

const char *base64_char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
const char *base64_url  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*$=";
+ (NSString *)base64:(NSData *) data
{
    unsigned char * s = (unsigned char *)[data bytes];
    int len = [data length],i=0,k=0;
    int t;
    unsigned char * d = (unsigned char *)malloc((len/3+1)*4 + 1);
    
    for(i=2,k=3;i<=len/3*3;i=i+3,k=k+4)
    {
        t=((s[i-2]>>2)&0xff);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2]&0x3)<<4)&0xff) + ((s[i-1]>>4)&0xf);
        d[k-2]=base64_url[t];
        
        t=((s[i-1]<<2)&0x3c) + ((s[i]>>6)&0x3);
        d[k-1]=base64_url[t];
        
        t=((s[i]>>6)&0x3f);
        d[k]=base64_url[t];
    }
    d[k-3]=0;
    if(len%3==1){
        // 1 byte
        t=((s[i-2]>>2)&0xff);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2]&0x3)<<4)&0xff);
        d[k-2]=base64_url[t];
        
        d[k-1]=base64_url[64];
        d[k]=base64_url[64];
        d[k+1]=0;
    }else if(len%3==2){
        t=((s[i-2]>>2)&0xff);
        d[k-3]=base64_url[t];
        
        t=(((s[i-2]&0x3)<<4)&0xff) + ((s[i-1]>>4)&0xf);
        d[k-2]=base64_url[t];
        
        t=((s[i-1]<<2)&0x3c);
        d[k-1]=base64_url[t];
        d[k]=base64_url[64];
        d[k+1]=0;
    }
    
//    [Prsa print_chars:d length:k+1];
    return [[NSString alloc] initWithUTF8String:(char *)d];
}